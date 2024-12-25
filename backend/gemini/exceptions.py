import time

class ResponseError(Exception):
    reason: str
    def __init__(self, reason: str):
        self.reason = reason
    
    def __str__(self):
        return f"Response failed: {self.reason}"

class EmptyInput(Exception):
    def __init__(self):
        super().__init__("Supplied input is empty")

class OnlineSourceError(Exception):
    reason: str
    def __init__(self, reason: str):
        self.reason = reason
    
    def __str__(self):
        return f"Response failed: {self.reason}"

class APILimitReached(Exception):
    limit: int | None
    renew_time: int | None # stored as epoch
    
    def __init__(self, limit: int | None = None, renew_time: int | None = None):
        super().__init__()
        self.limit = limit
        self.renew_time = renew_time
            
    def __str__(self):
        if self.limit != None and self.renew_time != None:
            renew_time_human = time.strftime("%H:%M", time.localtime(self.renew_time))
            return f"Limit reached {self.limit}, will renew at {renew_time_human}"
        elif self.limit != None:
            return f"Limit reached  {self.limit}"
        elif self.renew_time != None:
            renew_time_human = time.strftime("%H:%M", time.localtime(self.renew_time))
            return f"Limit reached, will renew at {renew_time_human}"
        else:
            return "Limit Reached"