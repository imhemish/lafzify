from abc import ABC, abstractmethod
from typing import List, Optional, Dict
from dataclasses import dataclass
from pymongo import MongoClient
from ..settings import settings

@dataclass
class Location:
    latitude: float
    longitude: float

class Platform(ABC):
    """
    Abstract base class for social media platforms.
    """
    # Platform identification
    human_name: str = "Generic Social Media Platform"
    id: str = "generic"
    
    # Posting capabilities
    supports_alt_txt: bool = False
    supports_threads: bool = False
    image_is_primary: bool = False
    max_char_length: int = 280
    supports_markdown: bool = False
    supports_basic_formatting: bool = False
    supports_polls: bool = False
    supports_location_tagging: bool = False
    supports_carousels: bool = False
    carousel_limit: int = 0
    supports_links: bool = True
    auto_recognises_links: bool = True
    supports_hashtags: bool = True
    max_hashtags: int = 30
    
    @abstractmethod
    def post_text(self,
                  text: str, 
                  location: Optional[Location] = None) -> str:
        """
        Post a text message to the platform.
        
        :param text: Text content to post
        :param location: Optional location for the post
        """
        pass
    
    @abstractmethod
    def post_carousel(self,
                      images: List[str], 
                      caption: str, 
                      location: Optional[Location] = None):
        """
        Post a carousel of images to the platform.
        
        :param images: List of image paths
        :param caption: Carousel caption
        :param location: Optional location for the post
        """
        pass
    
    @abstractmethod
    def post_image(self, images: str, caption: Optional[str] = "", location: Optional[Location] = None):
        """
        Post a single image to the platform.
        
        :param image: Image path
        :param caption: Image caption
        :param location: Optional location for the post
        """
        pass
    
    def post_poll(self, 
                  user_id: str,
                  quest: str, 
                  opts: List[str], 
                  duration_minutes: int = 1440):
        """
        Post a poll to the platform.
        
        :param user_id: ID of user according to Lafzify database
        :param quest: Poll question
        :param opts: Poll options
        :param duration_minutes: Poll duration in minutes
        """
        if not self.supports_polls:
            raise NotImplementedError(f"{self.human_name} does not support polls")
        
        if len(opts) < 2 or len(opts) > 4:
            raise ValueError("Polls must have 2-4 options")
        
        # Placeholder - to be implemented by specific platforms
        raise NotImplementedError(f"Poll posting not implemented for {self.human_name}")