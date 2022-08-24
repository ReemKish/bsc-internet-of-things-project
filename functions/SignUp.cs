using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace Arc.Function
{
    public static class SignUp
    {
        [FunctionName("SignUp")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = null)] HttpRequest req,
            [CosmosDB(
        databaseName: "arc_db_id",
        collectionName: "users",
        ConnectionStringSetting = "CosmosDbConnectionString")]IAsyncCollector<dynamic> documentsOut, ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            string name = data?.name;
            string phoneNumber = data?.phoneNumber;
            string email = data?.email;
            string password = data?.password;

            string responseMessage = data.ToString();

            if (!string.IsNullOrEmpty(name) && !string.IsNullOrEmpty(phoneNumber) && !string.IsNullOrEmpty(email) && !string.IsNullOrEmpty(password))
            {
                // Add a JSON document to the output container.
                await documentsOut.AddAsync(new
                {
                    // create a random ID
                    id = System.Guid.NewGuid().ToString(),
                    name = name,
                    phoneNumber = phoneNumber,
                    email = email,
                    password = password
                });
            }           
            return new OkObjectResult(responseMessage);
        }
    }
}
