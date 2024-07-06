import logging
from logging import Logger


class LoggerSingleton:
    _instance: Logger = None

    @classmethod
    def get_logger(cls) -> Logger:
        if cls._instance is None:
            cls._instance = logging.getLogger("app_logger")
            cls._instance.setLevel(logging.INFO)

            # Create handlers
            file_handler = logging.FileHandler("app.log")
            console_handler = logging.StreamHandler()

            # Set the log level for handlers
            file_handler.setLevel(logging.INFO)
            console_handler.setLevel(logging.INFO)

            # Create formatters and add them to the handlers
            formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
            file_handler.setFormatter(formatter)
            console_handler.setFormatter(formatter)

            # Add handlers to the logger
            cls._instance.addHandler(file_handler)
            cls._instance.addHandler(console_handler)

        return cls._instance
