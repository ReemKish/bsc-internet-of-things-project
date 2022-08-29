using System;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.Documents;
using Microsoft.Azure.Documents.Client;
using Microsoft.Azure.Documents.Linq;
using System.Linq;
using System.Collections.Generic;

namespace Arc.Function {
    class Database {
        static string DB_NAME = "arc_db_id";
        public enum Containers {
            users,
            devices
        };
        public static async Task<FullUser> getSingleUserByEmail(DocumentClient client, string email, ILogger log){
            //Search for follower based on email
            Uri usersUri = UriFactory.CreateDocumentCollectionUri(DB_NAME, Containers.users.ToString());

            log.LogInformation($"Searching for email: {email}");
            FeedOptions options = new FeedOptions { EnableCrossPartitionQuery = true }; // Enable cross partition query

            IDocumentQuery<FullUser> query = client.CreateDocumentQuery<FullUser>(usersUri, options)
                .Where(p => p.Email.Equals(email))
                .AsDocumentQuery();
            while (query.HasMoreResults) {
                foreach (FullUser user in await query.ExecuteNextAsync()) {
                    return user;
                }
            }
            return null;
        }
        public static async Task<Device> GetDeviceById(DocumentClient client, string deviceId, ILogger log){
            Uri uri = UriFactory.CreateDocumentCollectionUri(DB_NAME, Containers.devices.ToString());

            log.LogInformation($"Searching for: {deviceId}");
            FeedOptions options = new FeedOptions { EnableCrossPartitionQuery = true }; // Enable cross partition query

            IDocumentQuery<Device> query = client.CreateDocumentQuery<Device>(uri, options)
                .Where(p => p.DeviceId.Equals(deviceId))
                .AsDocumentQuery();
            while (query.HasMoreResults) {
                foreach (Device device in await query.ExecuteNextAsync()) {
                    return device;
                }
            }
            return null;
        }

        public static async Task<Device> DeleteDeviceById(DocumentClient client, string deviceId, ILogger log){
            Uri uri = UriFactory.CreateDocumentCollectionUri(DB_NAME, Containers.devices.ToString());

            log.LogInformation($"Searching for: {deviceId}");
            FeedOptions options = new FeedOptions { EnableCrossPartitionQuery = true }; // Enable cross partition query

            IDocumentQuery<Device> query = client.CreateDocumentQuery<Device>(uri, options)
                .Where(p => p.DeviceId.Equals(deviceId))
                .AsDocumentQuery();
            while (query.HasMoreResults) {
                foreach (Device device in await query.ExecuteNextAsync()) {
                    Uri deleteUri = UriFactory.CreateDocumentUri(DB_NAME, Containers.devices.ToString(),device.Id);
                    await client.DeleteDocumentAsync(deleteUri, new RequestOptions { PartitionKey = new PartitionKey(device.Id) });
                    return device;
                }
            }
            return null;
        }

        public static async Task<FullUser> getSingleUserByDeviceId(DocumentClient client, string deviceId, ILogger log){
            Device device = await GetDeviceById(client, deviceId, log);
            if (device == null) {
                return null;
            }
            List<FullUser> users = await getUsersByIds(client, new string[]{device.UserId}, log);
            if (users != null) {
                return users.ElementAt(0);
            }
            return null;
        }

        public static async Task<List<BasicUser>> getBasicUsersByIds(DocumentClient client, string[] ids, ILogger log){
            List<FullUser> users = await getUsersByIds(client, ids, log);
            List<BasicUser> basicUsers = new List<BasicUser>();
            foreach (FullUser user in users) {
                basicUsers.Add(user.getBasicUser());
            }
            return basicUsers;
        }
        public static async Task<List<FullUser>> getUsersByIds(DocumentClient client, string[] ids, ILogger log){
            
            List<FullUser> userList = new List<FullUser>();

            //Search for follower based on email
            Uri uri = UriFactory.CreateDocumentCollectionUri(DB_NAME, Containers.users.ToString());

            log.LogInformation($"Searching for user ids: {ids}");
            FeedOptions options = new FeedOptions { EnableCrossPartitionQuery = true }; // Enable cross partition query

            // Just for fun, I'll do it with an SQL expression this time
            string sqlExpression = "SELECT * FROM c where c.id IN " + "('" + string.Join( "','", ids) + "')";
            IDocumentQuery<FullUser> query = client.CreateDocumentQuery<FullUser>(uri, sqlExpression, options)
            .AsDocumentQuery();

            while (query.HasMoreResults)
            {
                foreach (FullUser db_user in await query.ExecuteNextAsync())
                {
                    userList.Add(db_user);
                }
            }
            return userList;
        }
    }
}