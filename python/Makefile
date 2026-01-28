all: check run test build-docs-html clean

run:
	uv run python -m src

check: clean
	uv run ruff format .
	uv run ruff check .
	uv run mypy --strict --explicit-package-bases .

test: clean
	uv run pytest -s -vv --cov=src --cov-report=term-missing \
			--cov-report=html

clean:
	py3clean . && rm -rf htmlcov __pycache__ .mypy_cache .ruff_cache .coverage.*

build-docs-html:
	cd docs && uv run make clean html SPHINXOPTS="-W --keep-going -n" && \
	        xdg-open build/html/index.html
