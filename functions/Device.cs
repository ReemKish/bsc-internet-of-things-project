using Newtonsoft.Json;

namespace Arc.Function
{
    public class Device
    {
        [JsonProperty("id")]
        public string Id { get; set; }
        [JsonProperty("device_id")]
        public string DeviceId { get; set; }
        [JsonProperty("user_id")]
        public string UserId { get; set; }
    }
}