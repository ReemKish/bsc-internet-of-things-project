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
using Microsoft.Azure.Documents.Linq;
using System.Linq;

namespace Arc.Function
{
    public static class RegisterDevice
    {
        [FunctionName("RegisterDevice")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = null)] HttpRequest req,
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

            if (string.IsNullOrEmpty(deviceId) || string.IsNullOrEmpty(email))
            {
                return new BadRequestResult();
            } else 
            {

                //Check if device is owned already
                Uri devicesUri = UriFactory.CreateDocumentCollectionUri("arc_db_id", "devices");
                log.LogInformation($"Searching for device id: {deviceId}");
                IDocumentQuery<Device> devicesQuery = client.CreateDocumentQuery<Device>(devicesUri, options)
                                .Where(p => p.DeviceId.Equals(deviceId))
                                .AsDocumentQuery();

                while (devicesQuery.HasMoreResults)
                {
                    foreach (Device db_device in await devicesQuery.ExecuteNextAsync())
                    {
                        return new ConflictResult();
                    }
                }
            
                //Search for user_id based on email
                Uri usersUri = UriFactory.CreateDocumentCollectionUri("arc_db_id", "users");

                log.LogInformation($"Searching for: {email}");
    
                IDocumentQuery<FullUser> usersQuery = client.CreateDocumentQuery<FullUser>(usersUri, options)
                    .Where(p => p.Email.Contains(email))
                    .AsDocumentQuery();

                while (usersQuery.HasMoreResults) {
                    foreach (FullUser db_user in await usersQuery.ExecuteNextAsync()) {
                        // Add a JSON document to the output container.
                        await devicesDocumentsOut.AddAsync(new
                        {
                            // create a random ID
                            id = System.Guid.NewGuid().ToString(),
                            device_id = deviceId,
                            user_id = db_user.Id,
                        });
                        
                        // Send update of new user
                        db_user.DeviceId = deviceId;
                        await usersDocumentsOut.AddAsync(JsonConvert.SerializeObject(db_user));
                        
                        return new OkObjectResult($"DeviceId {deviceId} was registered successfully to user {email}.");
                    }
                    return new NoContentResult();
                }
            }
            return new NotFoundResult();
        }
    }
}
