using Newtonsoft.Json;

namespace Arc.Function
{

    public class BasicUser
    {
        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("email")]
        public string Email { get; set; }
        [JsonProperty("phoneNumber")]
        public string PhoneNumber { get; set; }

        [JsonProperty("device_id")]
        public string DeviceId { get; set; }
    }

    public class FollowExtendedUser : BasicUser
    {
        [JsonProperty("following")]
        public string[] Following { get; set; }
        [JsonProperty("followed_by")]
        public string[] FollowedBy { get; set; }
    }

      public class PopulatedFollowUser : BasicUser
    {
        [JsonProperty("following")]
        public BasicUser[] Following { get; set; }
        [JsonProperty("followed_by")]
        public BasicUser[] FollowedBy { get; set; }
    }
    
    

    public class FullUser : FollowExtendedUser
    {
        [JsonProperty("id")]
        public string Id { get; set; }
        [JsonProperty("password")]
        public string Password { get; set; }
    }
}