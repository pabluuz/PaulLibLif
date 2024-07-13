from services.logging import LoggerSingleton
from services.mod_loader_service import YamlToXmlConverter
from legacy.konwerter import LegacyConverter


def run_server() -> None:
    logger = LoggerSingleton.get_logger()
    logger.info("Running server")
    logger.info("Building data from PaulMods")
    loader_service = YamlToXmlConverter("../PaulMods/", "../data/objects_types.xml")
    loader_service.convert()
    logger.info("PaulMods loaded to XMLs. Now it's time for SQL")
    converter = LegacyConverter()
    converter.convert()
