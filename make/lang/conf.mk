#
# CONF.MK --Rules for building config files.
#
# Contents:
# shell-build:         --Make scripts "executable".
# conf-src-var-defined: --Test if "enough" of the conf SRC vars. are defined.
# conf-toc:            --Build the table-of-contents for conf, awk files.
# conf-src:            --conf-specific customisations for the "src" target.
# todo:                --Report unfinished work (identified by keyword comments)
#

#
# %.conf: --Rules for installing config files.
#
$(sysconfdir)/%:	%.conf;		$(INSTALL_DATA) $? $@
$(divertdir)/%:		%.conf;		$(INSTALL_DATA) $? $@

$(sysconfdir)/%.conf:	%.conf;		$(INSTALL_DATA) $? $@
$(sysconfdir)/%.cfg:	%.cfg;		$(INSTALL_DATA) $? $@
$(sysconfdir)/%.ini:	%.ini;		$(INSTALL_DATA) $? $@

$(divertdir)/%.conf:	%.conf;		$(INSTALL_DATA) $? $@
$(divertdir)/%.cfg:	%.cfg;		$(INSTALL_DATA) $? $@
$(divertdir)/%.ini:	%.ini;		$(INSTALL_DATA) $? $@

#
# shell-build: --Make scripts "executable".
#
pre-build:	conf-src-var-defined

#
# conf-src-var-defined: --Test if "enough" of the conf SRC vars. are defined.
#
conf-src-var-defined:
	@test -n "$(CONF_SRC)" -o -n "$(CFG_SRC)" || \
	    { $(VAR_UNDEFINED) "CONF_SRC or CFG_SRC"; }

#
# conf-toc: --Build the table-of-contents for conf, awk files.
#
.PHONY: conf-toc
toc:	conf-toc
conf-toc:
	@$(ECHO) "++ make[$@]@$$PWD"
	mk-toc $(CONF_SRC) $(CFG_SRC) $(INI_SRC)

#
# conf-src: --conf-specific customisations for the "src" target.
#
src:	conf-src
.PHONY:	conf-src
conf-src:	
	@$(ECHO) "++ make[$@]@$$PWD"
	@mk-filelist -qn CONF_SRC *.conf
	@mk-filelist -qn CFG_SRC *.cfg
	@mk-filelist -qn INI_SRC *.ini

#
# todo: --Report unfinished work (identified by keyword comments)
# 
.PHONY: conf-todo
todo:	conf-todo
conf-todo:
	@$(ECHO) "++ make[$@]@$$PWD"
	@$(GREP) -e TODO -e FIXME -e REVISIT $(CONF_SRC) $(CFG_SRC) /dev/null || true