from services.logging import LoggerSingleton
from services.mod_loader_service import YamlToXmlConverter


def run_server() -> None:
    logger = LoggerSingleton.get_logger()
    logger.info("Running server")
    logger.info("Building data from PaulMods")
    loader_service = YamlToXmlConverter("../PaulMods/", "../data/objects_types.xml")
    result_converter = loader_service.convert()
    if result_converter is False:
        # Again! We had troubles with IDs, there were not yet there
        logger.info(
            "Trying to build data from PaulMods again, because we needed IDs that were not yet there. It's normal"
        )
        loader_service.convert()
