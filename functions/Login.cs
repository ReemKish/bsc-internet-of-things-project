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
    public static class Login
    {
        [FunctionName("Login")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            [CosmosDB(
                databaseName: "arc_db_id",
                collectionName: "users",
                ConnectionStringSetting = "CosmosDbConnectionString")] DocumentClient client,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            string email = data?.email;
            string password = data?.password;

            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
                {
                    return new UnauthorizedResult();
                }
            Uri collectionUri = UriFactory.CreateDocumentCollectionUri("arc_db_id", "users");

            log.LogInformation($"Searching for: {email}");

            var options = new FeedOptions { EnableCrossPartitionQuery = true }; // Enable cross partition query
 
            IDocumentQuery<User> query = client.CreateDocumentQuery<User>(collectionUri, options)
                .Where(p => p.Email.Contains(email))
                .AsDocumentQuery();

            while (query.HasMoreResults)
            {
                foreach (User db_user in await query.ExecuteNextAsync())
                {
                    log.LogInformation(db_user.Email);
                    if (db_user.Password == password) {
                        UserResponse u = new UserResponse(db_user);
                        return new OkObjectResult(JsonConvert.SerializeObject(u));
                    }
                }
            }
            return new UnauthorizedResult();
        }
    }
}
