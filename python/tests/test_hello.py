import asyncio
import time

from _pytest.capture import CaptureFixture

from src.main import main


def test_main(capsys: CaptureFixture[str]) -> None:
    result = main()
    out, err = capsys.readouterr()

    assert result == 0
    assert not err
    assert out == "Hello!\n"


async def test_async_stuff() -> None:
    start = time.perf_counter()
    await asyncio.sleep(1.0)
    end = time.perf_counter()

    assert end - start >= 1.0
