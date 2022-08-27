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
using System.Collections.Generic;

namespace Arc.Function
{
    public static class Login
    {
        public static async Task<List<BasicUser>> getBasicUsersByIds(DocumentClient client, Uri collectionUri, FeedOptions options, string[] ids){
            
            List<BasicUser> userList = new List<BasicUser>();
            // Just for fun, I'll do it with an SQL expression this time
            string sqlExpression = "SELECT * FROM c where c.id IN " + "('" + string.Join( "','", ids) + "')";
            IDocumentQuery<FullUser> query = client.CreateDocumentQuery<FullUser>(collectionUri, sqlExpression, options)
            .AsDocumentQuery();

            while (query.HasMoreResults)
            {
                foreach (FullUser db_user in await query.ExecuteNextAsync())
                {
                    userList.Add(db_user.getBasicUser());
                }
            }
            return userList;
        }

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
 
            IDocumentQuery<FullUser> query = client.CreateDocumentQuery<FullUser>(collectionUri, options)
                .Where(p => p.Email.Equals(email))
                .AsDocumentQuery();

            while (query.HasMoreResults)
            {
                foreach (FullUser db_user in await query.ExecuteNextAsync())
                {
                    log.LogInformation(db_user.Email);
                    if (db_user.Password.Equals(password)) {
                        //Login granted, get data for display.
                        BasicUser[] followingArray = null;
                        BasicUser[] followedByArray = null;
                        if (db_user.Following != null && db_user.Following.Length > 0){
                            List<BasicUser> followingList = await getBasicUsersByIds(client,collectionUri,options,db_user.Following);
                            followingArray = followingList.ToArray();
                        }
                        if (db_user.FollowedBy != null && db_user.FollowedBy.Length > 0){
                            List<BasicUser> followedByList = await getBasicUsersByIds(client,collectionUri,options,db_user.FollowedBy);
                            followedByArray = followedByList.ToArray();
                        }
                        PopulatedFollowUser populatedFollowUser = new PopulatedFollowUser(db_user, followingArray, followedByArray);
                        return new OkObjectResult(JsonConvert.SerializeObject(populatedFollowUser, Formatting.Indented, new JsonSerializerSettings
                        {
                            NullValueHandling = NullValueHandling.Ignore
                        }));
                    }
                }
            }
            return new UnauthorizedResult();
        }
    }
}
