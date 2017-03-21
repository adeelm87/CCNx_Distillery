#
# Copyright (c) 2015-2016, Xerox Corporation (Xerox) and Palo Alto Research Center, Inc (PARC)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright
#   notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL XEROX OR PARC BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# ################################################################################
# #
# # PATENT NOTICE
# #
# # This software is distributed under the BSD 2-clause License (see LICENSE
# # file).  This BSD License does not make any patent claims and as such, does
# # not act as a patent grant.  The purpose of this section is for each contributor
# # to define their intentions with respect to intellectual property.
# #
# # Each contributor to this source code is encouraged to state their patent
# # claims and licensing mechanisms for any contributions made. At the end of
# # this section contributors may each make their own statements.  Contributor's
# # claims and grants only apply to the pieces (source code, programs, text,
# # media, etc) that they have contributed directly to this software.
# #
# # There is no guarantee that this section is complete, up to date or accurate. It
# # is up to the contributors to maintain their portion of this section and up to
# # the user of the software to verify any claims herein.
# #
# # Do not remove this header notification.  The contents of this section must be
# # present in all distributions of the software.  You may only modify your own
# # intellectual property statements.  Please provide contact information.
#
# - Palo Alto Research Center, Inc
# This software distribution does not grant any rights to patents owned by Palo
# Alto Research Center, Inc (PARC). Rights to these patents are available via
# various mechanisms. As of January 2016 PARC has committed to FRAND licensing any
# intellectual property used by its contributions to this software. You may
# contact PARC at cipo@parc.com for more information or visit http://www.ccnx.org
#

##############################################################
#
# CCNx Distillery project
#
# See LICENSE FILE
# Ignacio Solis <Ignacio.Solis@parc.com>
#
# This is the main Makefile for the Distillery CCNx distribution.
# It is in charge of pulling in all necessary modules to build a full CCNx
# system.
# There is normally no need to modify this file. You can run "make help" to get
# more information or you can go directly to the configuration files to modify
# behavior.

DISTILLERY_VERSION=2.0

default.target: help

all: install-all

##############################################################
# Variables
#
# Set some variables
DISTILLERY_STAMP=.distillery.stamp
REBUILD_DEPENDS=

##############################################################
# Load the configuration
#
# For more information please see config.default.mk
#
DISTILLERY_CONFIG_DIR ?= config
DISTILLERY_USER_CONFIG_DIR  ?= ${HOME}/.ccnx/distillery

DISTILLERY_DEFAULT_CONFIG ?= ${DISTILLERY_CONFIG_DIR}/config.mk
DISTILLERY_LOCAL_CONFIG   ?= ${DISTILLERY_CONFIG_DIR}/local/config.mk
DISTILLERY_USER_CONFIG    ?= ${DISTILLERY_USER_CONFIG_DIR}/config.mk

ifneq (,$(wildcard ${DISTILLERY_USER_CONFIG}))
    include ${DISTILLERY_USER_CONFIG}
    REBUILD_DEPENDS+=${DISTILLERY_USER_CONFIG}
else
    DISTILLERY_USER_CONFIG+="[Not Found]"
endif

ifneq (,$(wildcard ${DISTILLERY_LOCAL_CONFIG}))
    include ${DISTILLERY_LOCAL_CONFIG}
    REBUILD_DEPENDS+=${DISTILLERY_LOCAL_CONFIG}
endif

include ${DISTILLERY_DEFAULT_CONFIG}


##############################################################
# Set the paths
#
# PATH: add our install dir, build dependencies and system dependencies
# LD_RUN_PATH: add our install dir

export PATH := $(DISTILLERY_INSTALL_DIR)/bin:$(DISTILLERY_TOOLS_DIR)/bin:$(PATH)
#export LD_RUN_PATH := $(DISTILLERY_INSTALL_DIR)/lib
#export LD_LIBRARY_PATH := $(DISTILLERY_INSTALL_DIR)/lib
export CCNX_HOME
export FOUNDATION_HOME


##############################################################
# Modules
#
# Load the modules config. Please refer to that file for more information
DISTILLERY_MODULES_DIR=${DISTILLERY_CONFIG_DIR}/modules

# The modules variable is a list of modules. It will be populated by the
# modules config files.
modules=
modules_dir=

#include ${DISTILLERY_MODULES_DIR}/*.mk

include config/modules/000-distillery-update.mk
include config/modules/000-gitModule.mk
include config/modules/001-modules.mk
include config/modules/002-cmake-modules.mk
include config/modules/002-make-modules.mk
include config/modules/100-distillery.mk
include config/modules/110-longbow.mk
include config/modules/120-libparc.mk
include config/modules/210-libccnx-common.mk
include config/modules/220-libccnx-transport-rta.mk
include config/modules/230-libccnx-portal.mk
include config/modules/510-Metis.mk
include config/modules/511-Athena.mk
include config/modules/601-ccnxPing.mk
include config/modules/602-ccnxSimpleFileTransfer.mk
include config/modules/603-ccnxFileRepo.mk
include config/modules/701-MasterIDE.mk
include config/modules/900-sanity.mk

# Load user defined modules
DISTILLERY_USER_MODULES_DIR=${DISTILLERY_USER_CONFIG_DIR}/modules
ifneq (,$(wildcard ${DISTILLERY_USER_MODULES_DIR}))
    include ${DISTILLERY_USER_MODULES_DIR}/*.mk
else
    DISTILLERY_USER_MODULES_DIR+="[Not Found]"
endif

ifdef ${DISTILLERY_LOCAL_MODULES_DIR}
    include ${DISTILLERY_LOCAL_MODULES_DIR}/*.mk
else
    DISTILLERY_LOCAL_MODULES_DIR="[Undefined]"
endif


##############################################################
# Build variables and rules
#

# We're going to create lists of targets as convenience
modules_clean=$(modules:=.clean)
modules_check=$(modules:=.check)
modules_step=$(modules:=.step)
modules_average-coverage=$(modules:=.average-coverage)

# These are the basic build rules. They will call the module specific rules
install-all: install-directories pre-requisites ${modules}

#distillery-sync: distillery-update ${DISTILLERY_ROOT_DIR}/tools/bin/syncOriginMasterWithPARCUpstream
#	@${DISTILLERY_ROOT_DIR}/tools/bin/syncOriginMasterWithPARCUpstream

clobber: distclean
	@rm -rf ${CONFIGURE_CACHE_FILE}
	@rm -rf ${DISTILLERY_INSTALL_DIR}/bin
	@rm -rf ${DISTILLERY_INSTALL_DIR}/lib
	@rm -rf ${DISTILLERY_INSTALL_DIR}/include
	@rm -rf ${DISTILLERY_INSTALL_DIR}/share
	@rm -rf ${DISTILLERY_INSTALL_DIR}/etc
	@rm -rf ${DISTILLERY_XCODE_DIR}
	@rm -rf .*.stamp

clean: ${modules_clean}
	@rm -rf report.txt

distclean:
	@rm -rf ${DISTILLERY_BUILD_DIR}
	@rm -rf report.txt

#distillery-update:
#	@echo "Fetching Distillery..."
#	@git fetch --all
#	@git pull

distillery-upstream:
	git remote add ${DISTILLERY_GITHUB_UPSTREAM_NAME} ${DISTILLERY_GITHUB_UPSTREAM_REPO}

check: ${modules_check}

step: ${modules_step}

# From Distillery, 'make coverage' actually runs the summary version of coverage
# You can also run 'make <module>.coverage' to get the output showing each file and its coverage.
coverage: ${modules_average-coverage}

dependencies:
	@${MAKE} -C dependencies

dependencies.clean:
	@${MAKE} -C dependencies clean

dependencies.clobber:
	@${MAKE} -C dependencies clobber

pre-requisites:

help:
	@echo "Simple instructions: run \"make update step\""
	@echo
	@echo "---- Basic build targets ----"
	@echo "make help      - This help message"
	@echo "make info      - Show basic information"
	@echo "make status    - Show status of modules"
	@echo "make update    - git clone and pull the different modules to the head of master"
	@echo "make sync      - fetch all remotes, merge upstream master, push to origin master"
	@echo "make step      - Module by module: configure, compile and install all software"
	@echo "                  in the install directory (see make info) and run tests"
	@echo "make all       - Configure, compile and install all software in DISTILLERY_INSTALL_DIR"
	@echo "make check     - Run all the tests"
	@echo "make clobber   - Clean the build, remove the install software"
	@echo
	@echo "make sanity    - Run simple sanity checks to test that the build is functional"
	@echo
	@echo "make coverage          - Show the average coverage of each module."
	@echo "make <module>.coverage - Show the coverage of each file in the specified module."
	@echo
	@echo "---- Advanced targets ----"
	@echo "make nuke-all-modules - DANGEROUS! Clean all the modules to git checkout (git clean -dfx)"
	@echo "                      - You will lose all uncommitted changes"
	@echo "make clean       - Clean the build"
	@echo "make distclean   - Distclean the build"
	@echo "make *-debug     - make a target with DEBUG on (e.g. all-debug or check-debug)"
	@echo "make *-release   - make a target with RELEASE on (optimized)"
	@echo "make *-nopants   - make a target with NOPANTS on (no validation - use at your own risk)"
	@echo
	@echo "---- IDE support targets ----"
	@echo "make xcode               - Create xcode projects [only works on Mac]"
	@echo "make MasterIDE.xcode     - Makes an xcode uber-project (based on all-debug) that contains"
	@echo "                         - the various sub-mdules"
	@echo "make MasterIDE.xcodeopen - Makes MasterIDE.xcode and the starts xcode"
	@echo "make MasterIDE.clionopen - Creates an uber CMakeLists.txt and starts CLion with the necessary"
	@echo "                         - environment for development"
	@echo
	@echo "---- Basic module targets ----"
	@echo "Module Directory  = ${MODULES_DIRECTORY_DEFAULT}"
	@echo "Modules Loaded    = ${modules}"
	@echo "GitModules Loaded = ${gitmodules}"
	@echo "Per-module targets: \"Module\" \"Module.distclean\" \"Module.nuke\" \"Module-debug\""


${DISTILLERY_STAMP}: ${REBUILD_DEPENDS}
	touch $@

debug-%: export CMAKE_BUILD_TYPE_FLAG = -DCMAKE_BUILD_TYPE=DEBUG
debug-%: export DISTILLERY_BUILD_NAME = -debug
debug-%:
	@${MAKE} $*

%-debug: debug-% ;

release-%: export CMAKE_BUILD_TYPE_FLAG = "-DCMAKE_BUILD_TYPE=RELEASE"
release-%: export DISTILLERY_BUILD_NAME = -release
release-%:
	@${MAKE} $*

%-release: release-% ;

nopants-%: export CMAKE_BUILD_TYPE_FLAG = "-DCMAKE_BUILD_TYPE=NOPANTS"
nopants-%: export DISTILLERY_BUILD_NAME = -nopants
nopants-%:
	@${MAKE} $*

%-nopants: nopants-% ;

releasedebug-%: export CMAKE_BUILD_TYPE_FLAG = "-DCMAKE_BUILD_TYPE=RELWITHDEBINFO"
releasedebug-%: export DISTILLERY_BUILD_NAME = -releasedebug
releasedebug-%:
	@${MAKE} $*

%-releasedebug: releasedebug-% ;

install-directories:
	@mkdir -p ${DISTILLERY_INSTALL_DIR}/include
	@mkdir -p ${DISTILLERY_INSTALL_DIR}/lib
	@mkdir -p ${DISTILLERY_INSTALL_DIR}/bin

Distillery.report:
	@echo '###################################'
	@echo 'Distillery report'
	@echo "#" `date "+%Y-%m-%d %H:%M:%S"`
	@echo "#" `uname -sr` "-" `uname -pm`
	@echo "#" `uname -n`
	@echo "#" PATH=${PATH}

	@git status
	@git log -1
	@git diff -U1

report.txt:
	$(MAKE) report > report.txt
	@cat report.txt

distillery.checkout.error:
	@echo
	@echo ===========================================================
	@echo
	@echo DISTILLERY ERROR: You have not checked out a repository!
	@echo Please make sure to run \"make update\" at least once
	@echo
	@echo Otherwise there is a misconfigured module,
	@echo please check the module config files at .distillery/modules
	@echo
	@echo ===========================================================
	@echo


info:
	@echo "############ Distillery Info ##################"
	@${MAKE} env


# env produces shell interpretable output. It is read by some scripts.
# DO NOT ALTER THE FORMAT
env:
	@echo DISTILLERY_ROOT_DIR=${DISTILLERY_ROOT_DIR}
	@echo DISTILLERY_SOURCE_DIR=${DISTILLERY_SOURCE_DIR}
	@echo DISTILLERY_BUILD_DIR=${DISTILLERY_BUILD_DIR}
	@echo DISTILLERY_DEFAULT_CONFIG=${DISTILLERY_DEFAULT_CONFIG}
	@echo DISTILLERY_LOCAL_CONFIG=${DISTILLERY_LOCAL_CONFIG}
	@echo DISTILLERY_USER_CONFIG=${DISTILLERY_USER_CONFIG}
	@echo DISTILLERY_MODULES_DIR=${DISTILLERY_MODULES_DIR}
	@echo DISTILLERY_LOCAL_MODULES_DIR=${DISTILLERY_LOCAL_MODULES_DIR}
	@echo DISTILLERY_USER_MODULES_DIR=${DISTILLERY_USER_MODULES_DIR}
	@echo DISTILLERY_INSTALL_DIR=${DISTILLERY_INSTALL_DIR}
	@echo DISTILLERY_DEPENDENCIES_DIR=${DISTILLERY_DEPENDENCIES_DIR}
	@echo DISTILLERY_EXTERN_DIR=${DISTILLERY_EXTERN_DIR}
	@echo DISTILLERY_TOOLS_DIR=${DISTILLERY_TOOLS_DIR}
	@echo DISTILLERY_GITHUB_URL=${DISTILLERY_GITHUB_URL}
	@echo DISTILLERY_GITHUB_URL_USER=${DISTILLERY_GITHUB_URL_USER}
	@echo DISTILLERY_GITHUB_UPSTREAM_URL=${DISTILLERY_GITHUB_UPSTREAM_URL}
	@echo CCNX_DEPENDENCIES=${CCNX_DEPENDENCIES}
	@echo LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
	@echo LD_RUN_PATH=${LD_RUN_PATH}
	@echo CCNX_HOME=${CCNX_HOME}
	@echo PATH=${PATH}

.PHONY: dependencies
