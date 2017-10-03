.PHONY: all test clean docs clean-pyc clean-report clean-docs clean-coverage tag tag-release kodi-release
.DEFAULT_GOAL := all

SPHINXBUILD = sphinx-build
SPHINXPROJ = pluginvideotelekomsport
BUILDDIR = ./_build
SOURCEDIR = ./resources/lib
TEST_DIR = ./resources/test
COVERAGE_FILE = ./.coverage
COVERAGE_DIR = ./coverage
REPORT_DIR = ./report
DOCS_DIR = ./docs
FLAKE_FILES = ./addon.py,./setup.py,./resources/lib/Constants.py,./resources/lib/Utils.py,./resources/lib/Settings.py,./resources/lib/Cache.py,./resources/lib/Session.py,./resources/lib/ItemHelper.py,./resources/lib/ContentLoader.py
RADON_FILES = resources/lib/*.py ./addon.py ./setup.py
LINT_REPORT_FILE = ./report/lint.html
TEST_OPTIONS = -s --cover-package=resources.lib.Cache --cover-package=resources.lib.Constants --cover-package=resources.lib.ContentLoader --cover-package=resources.lib.Dialogs --cover-package=resources.lib.ItemHelper --cover-package=resources.lib.Session --cover-package=resources.lib.Settings --cover-package=resources.lib.Utils --cover-erase --with-coverage --cover-branches
I18N_FILES = resources/language/**/*.po

all: clean lint test docs

clean: clean-pyc clean-report clean-docs clean-coverage

clean-pyc:
		find . -name '*.pyc' -exec rm {} +
		find . -name '*.pyo' -exec rm {} +

clean-report:
		rm -rf $(REPORT_DIR)
		mkdir $(REPORT_DIR)

clean-docs:
		rm -rf $(BUILDDIR)

clean-coverage:
		rm $(COVERAGE_FILE) || exit 0
		rm -rf $(COVERAGE_DIR)
		mkdir $(COVERAGE_DIR)

lint:
		flake8 --filename=$(FLAKE_FILES)
		pylint addon setup resources --ignore=test --output-format=html > $(LINT_REPORT_FILE)
		radon cc $(RADON_FILES)
		dennis-cmd lint $(I18N_FILES)

test:
		nosetests $(TEST_DIR) $(TEST_OPTIONS) --cover-html --cover-html-dir=$(COVERAGE_DIR)

tag:
		if [ "$TRAVIS_TAG" != "" ]; then make tag-release; else make kodi-release; fi

tag-release:
		kodi-release -a -o ./Authors.md
		kodi-release -c -o ./Changelog.md
		kodi-release -n -o ./.next_version
		kodi-release -p -o ./.current_version
		kodi-release -l -o ./.last_changes
		kodi-release -u
		export BAR="foo"
		export NEXT_VERSION=$(kodi-release -n)
		export CURRENT_VERSION=$(cat ./.current_version)
		#export LATEST_CHANGES=`cat ./.last_changes`
	  echo "BRANCH: ${TRAVIS_BRANCH}"
	  echo "BAR: ${BAR}"	
	  echo "Next version: ${NEXT_VERSION}"
	  echo "Current version: ${CURRENT_VERSION}"
	  #echo "Latest changes: ${LATEST_CHANGES}"			
		git add -f ./Changelog.md
		git add -f ./Authors.md
		git add package.json
		git add addon.xml
		git status
		git commit -m "chore(version): Version bump  [ci skip]"
		git tag $NEXT_VERSION
		git tag
		git status

kodi-release:
	CURRENT_VERSION=`kodi-release -p`
	LAST_CHANGES=`kodi-release -l`
	echo "$CURRENT_VERSION"		
	echo "$LAST_CHANGES"

docs:
	@$(SPHINXBUILD) $(DOCS_DIR) $(BUILDDIR) -T -c ./docs

help:
		@echo "    clean-pyc"
		@echo "        Remove python artifacts."
		@echo "    clean-report"
		@echo "        Remove coverage/lint report artifacts."
		@echo "    clean-docs"
		@echo "        Remove sphinx artifacts."
		@echo "    clean-coverage"
		@echo "        Remove code coverage artifacts."
		@echo "    lint"
		@echo "        Check style with flake8, pylint & radon"
		@echo "    test"
		@echo "        Run unit tests"
		@echo "    docs"
		@echo "        Generate sphinx docs"
