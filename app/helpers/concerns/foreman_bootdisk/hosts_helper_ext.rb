# frozen_string_literal: true

module ForemanBootdisk
  module HostsHelperExt
    def host_title_actions(*args)
      if @host.bootdisk_downloadable?
        title_actions(
          button_group(
            select_action_button(
              _('Boot disk'), { class: 'btn btn-group' },
              display_bootdisk_link_if_authorized(
                _("Host '%s' image") % @host.name.split('.')[0],
                {
                  controller: 'foreman_bootdisk/disks',
                  action: 'host',
                  id: @host
                },
                class: 'la'
              ),
              display_bootdisk_link_if_authorized(
                _("Full host '%s' image") % @host.name.split('.')[0],
                {
                  controller: 'foreman_bootdisk/disks',
                  action: 'full_host',
                  id: @host
                },
                class: 'la'
              ),
              content_tag(:li, '', class: 'divider'),
              display_bootdisk_link_if_authorized(
                _('Generic image'),
                {
                  controller: 'foreman_bootdisk/disks',
                  action: 'generic'
                },
                class: 'la'
              ),
              display_bootdisk_for_subnet,
              content_tag(:li, '', class: 'divider'),
              display_bootdisk_link_if_authorized(
                _('Help'), {
                  controller: 'foreman_bootdisk/disks',
                  action: 'help'
                },
                class: 'la'
              )
            )
          )
        )
      else
        bootdisk_button_disabled
      end

      super
    end

    def bootdisk_button_disabled
      title_actions(
        button_group(
          link_to(_('Boot disk'), '#', disabled: true, class: 'btn btn-default',
                                       title: _('Boot disk download not available for %s architecture') % @host.architecture.name)
        )
      )
    end

    # need to wrap this one in a test for template proxy presence
    def display_bootdisk_for_subnet
      if (proxy = @host.try(:subnet).try(:tftp)) && proxy.has_feature?('Templates')
        display_bootdisk_link_if_authorized(
          _("Subnet '%s' generic image") % @host.subnet.name, {
            controller: 'foreman_bootdisk/disks',
            action: 'subnet',
            id: @host
          },
          class: 'la'
        )
      else
        ''
      end
    end

    # Core Foreman helpers can't look up a URL against a mounted engine
    def display_bootdisk_link_if_authorized(name, options = {}, html_options = {})
      if bootdisk_authorized_for(options)
        link_to(name, bootdisk_url(options), html_options)
      else
        ''
      end
    end

    def bootdisk_url(options)
      ForemanBootdisk::Engine.routes.url_for(options.merge(only_path: true, script_name: foreman_bootdisk_path))
    end

    def bootdisk_authorized_for(options)
      User.current.allowed_to?(options)
    end
  end
end
