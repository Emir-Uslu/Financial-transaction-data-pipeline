import logging
from pathlib import Path
from datetime import datetime
from config import BASE_DIR

def setup_logger():
    log_dir = BASE_DIR / "logs"
    log_dir.mkdir(exist_ok=True)
    filename = log_dir / f"pipeline_{datetime.now():%Y%m%d}.log"

    logger = logging.getLogger("financial_pipeline")
    logger.setLevel(logging.INFO)

    if not logger.handlers:
        formatter = logging.Formatter(
            "%(asctime)s | %(levelname)s | %(message)s"
        )

        file_handler = logging.FileHandler(filename, encoding="utf-8")
        file_handler.setFormatter(formatter)

        console_handler = logging.StreamHandler()
        console_handler.setFormatter(formatter)

        logger.addHandler(file_handler)
        logger.addHandler(console_handler)

    return logger
