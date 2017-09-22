.PHONY: all test clean clean-pyc clean-report clean-docs clean-coverage
.DEFAULT_GOAL := all

SOURCEDIR = ./resources/lib
TEST_DIR = ./resources/test
COVERAGE_FILE = ./.coverage
COVERAGE_DIR = ./coverage
REPORT_DIR = ./report
DOCS_DIR = ./docs
FLAKE_FILES = ./addon.py,./setup.py,./resources/lib/Constants.py,./resources/lib/Utils.py,./resources/lib/Settings.py,./resources/lib/Cache.py,./resources/lib/Session.py,./resources/lib/ItemHelper.py,./resources/lib/ContentLoader.py
RADON_FILES = resources/lib/*.py ./addon.py ./setup.py
LINT_REPORT_FILE = ./report/lint.html
TEST_REPORT_FILE = ./report/test_result.txt
TEST_OPTIONS = -s --cover-package=resources.lib.Cache --cover-package=resources.lib.Constants --cover-package=resources.lib.ContentLoader --cover-package=resources.lib.Dialogs --cover-package=resources.lib.ItemHelper --cover-package=resources.lib.Session --cover-package=resources.lib.Settings --cover-package=resources.lib.Utils --cover-erase --with-coverage --cover-branches

all: clean lint test

clean: clean-pyc clean-report clean-docs clean-coverage

clean-pyc:
	find . -name '*.pyc' -exec rm {} +
	find . -name '*.pyo' -exec rm {} +

clean-report:
	rm -rf $(REPORT_DIR)
	mkdir $(REPORT_DIR)

clean-docs:
	rm -rf $(DOCS_DIR)
	mkdir $(DOCS_DIR)

clean-coverage:
	rm $(COVERAGE_FILE)
	rm -rf $(COVERAGE_DIR)
	mkdir $(COVERAGE_DIR)

lint:
	flake8 --filename=$(FLAKE_FILES)
	pylint addon setup resources --ignore=test --output-format=html > $(LINT_REPORT_FILE) || exit 0
	pylint addon setup resources --ignore=test --output-format=colorized
	radon cc $(RADON_FILES)

test:
	nosetests $(TEST_DIR) $(TEST_OPTIONS) --cover-html --cover-html-dir=$(COVERAGE_DIR) > $(TEST_REPORT_FILE)
	nosetests $(TEST_DIR) $(TEST_OPTIONS)


help:
	@echo "    clean-pyc"
	@echo "        Remove python artifacts."
	@echo "    clean-report"
	@echo "        Remove coverage/lint report artifacts."
	@echo "    clean-docs"
	@echo "        Remove pydoc artifacts."	
	@echo "    clean-coverage"
	@echo "        Remove code coverage artifacts."
	@echo "    lint"
	@echo "        Check style with flake8, pylint & radon"	
	@echo "    test"
	@echo "        Run unit tests"