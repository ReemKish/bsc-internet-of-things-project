using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Azure.Documents.Client;

namespace Arc.Function
{
    public static class RegisterDevice
    {
        [FunctionName("RegisterDevice")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Admin, "post", Route = null)] HttpRequest req,
            [CosmosDB(
        databaseName: "arc_db_id",
        collectionName: "devices",
        ConnectionStringSetting = "CosmosDbConnectionString")]IAsyncCollector<dynamic> devicesDocumentsOut, 
        [CosmosDB(
        databaseName: "arc_db_id",
        collectionName: "users",
        ConnectionStringSetting = "CosmosDbConnectionString")]IAsyncCollector<dynamic> usersDocumentsOut, 
        [CosmosDB(
                databaseName: "arc_db_id",
                collectionName: "users",
                ConnectionStringSetting = "CosmosDbConnectionString")] DocumentClient client, ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            string deviceId = data?.deviceId;
            string email = data?.email;

            var options = new FeedOptions { EnableCrossPartitionQuery = true }; // Enable cross partition query

            if (string.IsNullOrEmpty(email)) {
                return new BadRequestResult();
            } else {
                if (!string.IsNullOrEmpty(deviceId)){
                    //Check if device is owned already
                    Device device = await Database.GetDeviceById(client, deviceId, log);
                    if (device != null){
                        return new ConflictResult();
                    }
                    FullUser user = await Database.getSingleUserByEmail(client, email, log);
                    if (user == null){
                        return new BadRequestResult();
                    }
                    // Add a JSON document to the output container.
                    await devicesDocumentsOut.AddAsync(new
                    {
                        // create a random ID
                        id = System.Guid.NewGuid().ToString(),
                        device_id = deviceId,
                        user_id = user.Id,
                    });
                    
                    // Send update of new user
                    user.DeviceId = deviceId;
                    await usersDocumentsOut.AddAsync(JsonConvert.SerializeObject(user));
                    
                    return new OkObjectResult($"DeviceId {deviceId} was registered successfully to user {email}.");
                } else {
                    FullUser user = await Database.getSingleUserByEmail(client, email, log);
                    if (user == null){
                        return new BadRequestResult();
                    }
                    if (user.DeviceId == null)
                    return new OkObjectResult($"User {email} has no linked devices.");
                    else {
                        Device device = await Database.DeleteDeviceById(client, user.DeviceId, log);
                        user.DeviceId = null;
                        await usersDocumentsOut.AddAsync(JsonConvert.SerializeObject(user, Formatting.Indented, new JsonSerializerSettings
                            {
                                NullValueHandling = NullValueHandling.Ignore
                            }));
                        return new OkObjectResult($"User {email} has no linked devices now.");
                    }
                }                    
            }
        }
    }
}