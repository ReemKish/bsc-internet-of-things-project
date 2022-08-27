using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Azure.Documents.Client;
using System.Collections.Generic;

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
            
            FullUser db_user = await Database.getSingleUserByEmail(client, email, log);

            log.LogInformation(db_user.Email);
            if (db_user.Password.Equals(password)) {
                //Login granted, get data for display.
                BasicUser[] followingArray = null;
                BasicUser[] followedByArray = null;
                if (db_user.Following != null && db_user.Following.Length > 0){
                    List<BasicUser> followingList = await Database.getBasicUsersByIds(client, db_user.Following, log);
                    followingArray = followingList.ToArray();
                }
                if (db_user.FollowedBy != null && db_user.FollowedBy.Length > 0){
                    List<BasicUser> followedByList = await Database.getBasicUsersByIds(client, db_user.FollowedBy, log);
                    followedByArray = followedByList.ToArray();
                }
                PopulatedFollowUser populatedFollowUser = new PopulatedFollowUser(db_user, followingArray, followedByArray);
                return new OkObjectResult(JsonConvert.SerializeObject(populatedFollowUser, Formatting.Indented, new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore
                }));
            }
        
            
            return new UnauthorizedResult();
        }
    }
}
