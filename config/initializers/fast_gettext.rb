# You can create the letsbonus.po file from the separate *.po files with this command:
#
#    cd languages/es_ES
#    msgcat *.po > app.po
#
# msgcat is part of the gettext tools, which you can install with:
#
#    brew install gettext
#    brew link --force gettext
#
FastGettext.add_text_domain 'app', :path => 'languages', :type => :po
FastGettext.default_available_locales = ['es_ES']
FastGettext.default_text_domain = 'app'
