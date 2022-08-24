using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Azure.Messaging.EventHubs;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.Documents.Client;
using Newtonsoft.Json;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Documents.Linq;


namespace Arc.Function
{
    public static class FallDetection
    {
        [FunctionName("FallDetection")]
        public static async Task Run([EventHubTrigger("fall-detection-event-hub", Connection = "eventhubworkshop2022_iothubroutes_iothubworkshop082022_EVENTHUB")] EventData[] events, ILogger log
        ,IAsyncCollector<IDictionary<string,string>> notification,
        [CosmosDB(
                databaseName: "arc_db_id",
                collectionName: "users",
                ConnectionStringSetting = "CosmosDbConnectionString")] DocumentClient client)
        {
            var exceptions = new List<Exception>();

            foreach (EventData eventData in events)
            {
                try
                {
                    // Get the device id from event
                    string eventBody = Encoding.UTF8.GetString(eventData.EventBody);
                    log.LogInformation($"C# Event Hub trigger function processed a message: {eventBody}");
                    dynamic data = JsonConvert.DeserializeObject(eventBody);
                    string deviceId = data.deviceId;
                    
                    // Get users to call
                    List<string> mailArray = new List<string>();
                    Uri collectionUri = UriFactory.CreateDocumentCollectionUri("arc_db_id", "users");
                    var options = new FeedOptions { EnableCrossPartitionQuery = true }; // Enable cross partition query
                    IDocumentQuery<User> query = client.CreateDocumentQuery<User>(collectionUri, options)
                        .Where(p => p.DeviceId.Contains(deviceId))
                        .AsDocumentQuery();

                    while (query.HasMoreResults)
                    {
                        foreach (User db_user in await query.ExecuteNextAsync())
                        {
                            mailArray.Concat(db_user.FollowedBy);
                        }
                    }

                    //TODO: Eventually this should be join instead of direct email

                    //Send notifications to all email

                    await notification.AddAsync(GetTemplateProperties(myQueueItem));

                    await Task.Yield();
                }
                catch (Exception e)
                {
                    // We need to keep processing the rest of the batch - capture this exception and continue.
                    // Also, consider capturing details of the message that failed processing so it can be processed again later.
                    exceptions.Add(e);
                }
            }

            // Once processing of the batch is complete, if any messages in the batch failed processing throw an exception so that there is a record of the failure.

            if (exceptions.Count > 1)
                throw new AggregateException(exceptions);

            if (exceptions.Count == 1)
                throw exceptions.Single();
        }
        private static IDictionary<string, string> GetTemplateProperties(string message)
{
    Dictionary<string, string> templateProperties = new Dictionary<string, string>();
    templateProperties["user"] = "A new user wants to be added : " + message;
    return templateProperties;
}
    }
}
