import os

from src._logging import LOG

__all__ = ("main",)


def main() -> int:
    LOG.debug("logging works")
    print("Hello!")

    return os.EX_OK
