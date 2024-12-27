import tweepy
from typing import List, Optional
from ..settings import settings
from .platform import Platform
from .platform import Location
from ..api.secret_store import PlatformSecrets

class XPlatform(Platform):
    """
    Implementation of Platform for Twitter.
    """
    human_name = "X (Twitter)"
    id = "x"
    supports_alt_txt = True
    max_char_length = 280
    supports_location_tagging = False
    supports_links = True
    supports_polls = True

    def __init__(self, x_secrets: PlatformSecrets):
        self.access_token = x_secrets.access_token
        self.access_secret = x_secrets.access_secret
        self.consumer_key = x_secrets.api_key
        self.consumer_secret = x_secrets.api_secret
        self.api: tweepy.Client = self._authenticate()

    def _authenticate(self) -> tweepy.Client:
        """
        Authenticate with the Twitter API using user tokens.
        """
        auth = tweepy.Client(
            consumer_key=self.consumer_key, 
            consumer_secret=self.consumer_secret, 
            access_token=self.access_token, 
            access_token_secret=self.access_secret,
        )
        return auth

    def post_text(self, text: str, location: Optional[Location] = None) -> str:
        """
        Post a text tweet and returns link to post
        """
        if len(text) > self.max_char_length:
            raise ValueError(f"Text exceeds the maximum character limit of {self.max_char_length}.")
        try:
            lat = lon = None
            if location != None:
                lat = location.latitude
                lon = location.longitude
            
            tweet = self.api.create_tweet(text=text)
            print(f"Tweet posted successfully")
            return "https://x.com/i/web/status/"+tweet.data['id']
        except tweepy.TweepyException as e:
            print(f"Failed to post tweet: {e}")
            raise
    
    def post_carousel(self, user_id: str, images: List[str], caption: str, location: Location | None = None):
        raise NotImplementedError()
    def post_poll(self, user_id: str, quest: str, opts: List[str], duration_minutes: int = 1440):
        raise NotImplementedError()
    def post_image(self, user_id: str, images: str, caption: str | None = "", location: Location | None = None):
        raise NotImplementedError()
    


