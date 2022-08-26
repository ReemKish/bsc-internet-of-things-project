using System;
using System.Collections.Generic;
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
    public static class Follow
    {
        [FunctionName("Follow")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = null)] HttpRequest req,
            [CosmosDB(
                databaseName: "arc_db_id",
                collectionName: "users",
                ConnectionStringSetting = "CosmosDbConnectionString")]IAsyncCollector<dynamic> followerDocumentsOut, 
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
                // Find owner
                FullUser owner = null;
                Uri ownerUri = UriFactory.CreateDocumentCollectionUri("arc_db_id", "users");
                log.LogInformation($"Searching for device id: {deviceId}");
                IDocumentQuery<FullUser> ownerQuery = client.CreateDocumentQuery<FullUser>(ownerUri, options)
                                .Where(p => p.DeviceId.Equals(deviceId))
                                .AsDocumentQuery();

                while (ownerQuery.HasMoreResults)
                {
                    foreach (FullUser db_user in await ownerQuery.ExecuteNextAsync())
                    {
                        owner = db_user;
                    }
                }
            
                //Search for follower based on email
                Uri usersUri = UriFactory.CreateDocumentCollectionUri("arc_db_id", "users");

                log.LogInformation($"Searching for: {email}");
    
                IDocumentQuery<FullUser> followerQuery = client.CreateDocumentQuery<FullUser>(usersUri, options)
                    .Where(p => p.Email.Equals(email))
                    .AsDocumentQuery();
                while (followerQuery.HasMoreResults) {
                    foreach (FullUser follower in await followerQuery.ExecuteNextAsync()) {
                        
                        // Send update of new user and owner
                        List<string> followingList;
                        if (follower.Following == null){
                            followingList = new List<string>();
                            followingList.Add(owner.Id);
                        } else {
                        followingList = follower.Following.ToList();
                        followingList.Add(owner.Id);
                        }
                        follower.Following = followingList.ToArray();

                        List<string> followedByList;
                        if (owner.FollowedBy == null){
                            followedByList = new List<string>();
                            followedByList.Add(follower.Id);
                        } else {
                        followedByList = owner.FollowedBy.ToList();
                        followedByList.Add(follower.Id);
                        }
                        owner.FollowedBy = followedByList.ToArray();
                        
                        await followerDocumentsOut.AddAsync(JsonConvert.SerializeObject(follower));
                        await followerDocumentsOut.AddAsync(JsonConvert.SerializeObject(owner));
                        
                        //Return owner of device as response
                        //TODO: Still got issues with masking the results in an elegant manner.
                        return new OkObjectResult(JsonConvert.SerializeObject(
                            JsonConvert.DeserializeObject<BasicUser>(
                                JsonConvert.SerializeObject(owner)
                            )
                        ));
                    }
                    return new NoContentResult();
                }
            }
            return new NotFoundResult();
        }
    }
}
