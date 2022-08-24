using Newtonsoft.Json;

namespace Arc.Function
{
    public class UserResponse
    {
        public UserResponse(User user){
            this.Name = user.Name;
            this.Email = user.Email;
            this.HasDevice = user.DeviceId != null;
            this.Following = user.Following;
            this.FollowedBy = user.FollowedBy;
            this.IRequestedToFollow = user.IRequestedToFollow;
            this.OthersRequestedToFollowMe = user.OthersRequestedToFollowMe;
        }
        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("email")]
        public string Email { get; set; }

        [JsonProperty("has_device")]
        public bool HasDevice { get; set; }
        [JsonProperty("following")]
        public string[] Following { get; set; }
        [JsonProperty("followed_by")]
        public string[] FollowedBy { get; set; }
        [JsonProperty("i_requested_to_follow")]
        public string[] IRequestedToFollow { get; set; }
        [JsonProperty("others_requested_to_follow_me")]
        public string[] OthersRequestedToFollowMe { get; set; }
    }

    public class User 
    {
        [JsonProperty("id")]
        public string Id { get; set; }
        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("email")]
        public string Email { get; set; }
        [JsonProperty("password")]
        public string Password { get; set; }
        [JsonProperty("device_id")]
        public string DeviceId { get; set; }
        [JsonProperty("following")]
        public string[] Following { get; set; }
        [JsonProperty("followed_by")]
        public string[] FollowedBy { get; set; }
        [JsonProperty("i_requested_to_follow")]
        public string[] IRequestedToFollow { get; set; }
        [JsonProperty("others_requested_to_follow_me")]
        public string[] OthersRequestedToFollowMe { get; set; }
    }
}