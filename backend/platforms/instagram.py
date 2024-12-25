from .platform import Platform

class Instagram(Platform):
    human_name = "Instagram"
    supports_alt_txt = True
    supports_threads = False
    image_is_primary = True
    #max_char_length =
    supports_markdown = False
    #supports_basic_formatting =
    supports_polls = False
    supports_location_tagging = True
    supports_carousels = True
    #carousel_limit = 
    supports_links = False
    auto_recognises_links = False
    supports_hashtags = True
    max_hashtags: int | None
    
if __name__ == "__main__":
    inst = Instagram()
    print(inst.supports_alt_txt)