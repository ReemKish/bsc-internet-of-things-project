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
using System.Linq;

namespace Arc.Function
{
    public static class Follow
    {
        [FunctionName("Follow")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Admin, "post", Route = null)] HttpRequest req,
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
            bool delete = data?.delete != null ? data?.delete : false;

            var options = new FeedOptions { EnableCrossPartitionQuery = true }; // Enable cross partition query

            if (string.IsNullOrEmpty(deviceId) || string.IsNullOrEmpty(email))
            {
                return new BadRequestResult();
            } else 
            {
                // Find owner
                FullUser owner = await Database.getSingleUserByDeviceId(client, deviceId, log);
                if (owner == null) {
                    return new BadRequestResult();
                }
                //Find follower
                FullUser follower = await Database.getSingleUserByEmail(client, email, log);
                if (follower == null) {
                    return new BadRequestResult();
                }

                //Do not add if already following
                if (follower.Following != null && follower.Following.Contains(owner.Id) && !delete){
                    return new ConflictResult();
                }

                // Prepare follower update
                List<string> followingList = null;
                if (follower.Following == null) followingList = new List<string>();
                else followingList = follower.Following.ToList();
                if (delete) followingList.RemoveAll(s => s.Equals(owner.Id));
                else followingList.Add(owner.Id);
                follower.Following = followingList.ToArray();

                // Prepare owner update
                List<string> followedByList;
                if (owner.FollowedBy == null) followedByList = new List<string>();
                else followedByList = owner.FollowedBy.ToList();
                if (delete) followedByList.RemoveAll(s => s.Equals(follower.Id));
                else followedByList.Add(follower.Id);
                owner.FollowedBy = followedByList.ToArray();
                
                // Send updates
                await followerDocumentsOut.AddAsync(JsonConvert.SerializeObject(follower));
                await followerDocumentsOut.AddAsync(JsonConvert.SerializeObject(owner));
                
                //Return owner of device as response to the query
                BasicUser basicOwner = owner.getBasicUser();
                string response = delete ? "" : JsonConvert.SerializeObject(basicOwner, Formatting.Indented);
                return new OkObjectResult(response);
            }
        }
    }
}
