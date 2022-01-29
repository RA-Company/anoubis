##
# Additional procedures

def create_tenant(params = {})
  return nil if !params.has_key? :ident
  return nil if !params.has_key? :title

  tenant = Anubis::Tenant::Tenant.find_or_create_by ident: params[:ident]
  tenant.title = params[:title]
  if params.has_key? :default
    if params[:default]
      tenant.state = Anubis::Tenant::Tenant.states[:default]
    end
  end
  tenant.save

  Anubis::Tenant::TenantSystem.find_or_create_by tenant: tenant, system_id: 1

  return tenant
end

##
# Create multi languages menu element
def create_menu(params = {})
  return nil if !params.key? :mode
  return nil if !params.key? :action

  params[:access] = 'read' if !params.key? :access
  params[:state] = 'visible' if !params.key? :state

  prefix = 'install.menu.'+params[:mode].to_s

  if get_anubis_type == 'tenant'
    data = Anubis::Tenant::Menu.find_or_create_by(mode: params[:mode]) do |menu|
      menu.action = params[:action]
      menu.menu = params[:parent] if params.key? :parent
      menu.page_size = params[:page_size] if params.key? :page_size
      menu.state = params[:state]
    end

    I18n.available_locales.each do |locale|
      I18n.locale = locale
      Anubis::Tenant::MenuLocale.find_or_create_by(menu_id: data.id, locale: Anubis::Tenant::MenuLocale.locales[locale.to_s.to_sym]) do |menu_locale|
        menu_locale.title = I18n.t(prefix+'.title')
        menu_locale.page_title = I18n.t(prefix+'.page_title')
        menu_locale.short_title = I18n.t(prefix+'.short_title', default: [(prefix+'.title').to_sym])
      end
    end

    if params.has_key?(:group) && params.has_key?(:system)
      if params[:system].is_a? Array
        params[:system].each do |system|
          Anubis::Tenant::SystemMenu.find_or_create_by system: system, menu: data
        end
      else
        Anubis::Tenant::SystemMenu.find_or_create_by system: params[:system], menu: data
      end

      if params[:group].is_a? Array
        params[:group].each do |group|
          add_access_menu group: group, menu: data, access: params[:access]
        end
      else
        add_access_menu group: params[:group], menu: data, access: params[:access]
      end
    end
  end

  if get_anubis_type == 'sso-client'
    data = Anubis::Sso::Client::Menu.find_or_create_by(mode: params[:mode])

    #puts data.to_json

    if data
      data.action = params[:action]
      if params.key? :parent
        data.menu = params[:parent]
      else
        data.menu_id = nil
      end
      if params.key? :page_size
        data.page_size = params[:page_size]
      else
        data.page_size = 0
      end
      data.state = params[:state]

      I18n.available_locales.each do |locale|
        I18n.locale = locale
        data.title = I18n.t(prefix + '.title')
        data.page_title = I18n.t(prefix + '.page_title')
        data.short_title = I18n.t(prefix + '.short_title', default: [(prefix + '.title').to_sym])
      end

      data.save
      puts data.errors.full_messages


      if params.has_key?(:group)
        if params[:group].is_a? Array
          params[:group].each do |group|
            add_access_menu group: group, menu: data, access: params[:access]
          end
        else
          add_access_menu group: params[:group], menu: data, access: params[:access]
        end
      end
    end
  end

  return data
end

##
# Create multi languages system
def create_system(params = {})
  return nil if !params.has_key? :ident
  return nil if !params.has_key? :translate

  system = Anubis::Tenant::System.find_or_create_by ident: params[:ident]
  if system
    I18n.available_locales.each do |locale|
      I18n.locale = locale
      Anubis::Tenant::SystemLocale.find_or_create_by(system: system, locale: Anubis::Tenant::SystemLocale.locales[locale.to_s.to_sym]) do |system_locale|
        system_locale.title = I18n.t(params[:translate])
      end
    end
  end

  if params.has_key? :tenant
    if params[:tenant].is_a? Array
      params[:tenant].each do |tenant|
        Anubis::Tenant::TenantSystem.find_or_create_by tenant: tenant, system: system
      end
    else
      Anubis::Tenant::TenantSystem.find_or_create_by tenant: params[:tenant], system: system
    end
  end

  return system
end

##
# Create multi languages group
def create_group(params = {})
  return nil if !params.has_key? :ident
  return nil if !params.has_key? :translate

  if get_anubis_type == 'tenant'
    return nil if !params.has_key? :system

    group = Anubis::Tenant::Group.find_or_create_by ident: params[:ident], system: params[:system]
    if group
      I18n.available_locales.each do |locale|
        I18n.locale = locale
        Anubis::Tenant::GroupLocale.find_or_create_by(group: group, locale: Anubis::Tenant::GroupLocale.locales[locale.to_s.to_sym]) do |group_locale|
          group_locale.title = I18n.t(params[:translate])
        end
      end
    end

    if params.has_key? :user
      if params[:user].is_a? Array
        params[:user].each do |user|
          Anubis::Tenant::UserGroup.find_or_create_by group: group, user: user
        end
      else
        Anubis::Tenant::UserGroup.find_or_create_by group: group, user: params[:user]
      end
    end
  end

  if get_anubis_type == 'sso-client'
    group = Anubis::Sso::Client::Group.find_or_create_by ident: params[:ident]

    if group
      I18n.available_locales.each do |locale|
        I18n.locale = locale
        group.title = I18n.t(params[:translate])
      end
      group.save
    end
  end

  return group
end

def add_access_menu(params = {})
  return if !params.has_key? :group
  return if !params.has_key? :menu

  params[:access] = 'read' if !params.has_key? :access

  if %w[tenant sso-client].include? get_anubis_type
    group_menu_model = Anubis::Tenant::GroupMenu if get_anubis_type == 'tenant'
    group_menu_model = Anubis::Sso::Client::GroupMenu if get_anubis_type == 'sso-client'

    if params[:group].class == Array
      params[:group].each do |group|
        data = group_menu_model.find_or_create_by group: group, menu: params[:menu]
        if group_menu_model.accesses[params[:access].to_sym] > group_menu_model.accesses[data.access.to_sym]
          data.access = params[:access]
          data.save
        end
      end
    else
      data = group_menu_model.find_or_create_by group: params[:group], menu: params[:menu]
      if group_menu_model.accesses[params[:access].to_sym] > group_menu_model.accesses[data.access.to_sym]
        data.access = params[:access]
        data.save
      end
    end
  end
end

def get_anubis_type
  begin
    type = Rails.configuration.anubis_type
  rescue
    type = 'tenant'
  end

  type
end


if get_anubis_type == 'tenant'
  ##
  # Create default system with id 1
  system = Anubis::Tenant::System.find_by_id(1)
  if !system
    system = Anubis::Tenant::System.create(id: 1)
  end
  I18n.available_locales.each do |locale|
    I18n.locale = locale
    Anubis::Tenant::SystemLocale.find_or_create_by(system_id: system.id, locale: Anubis::Tenant::SystemLocale.locales[locale.to_s.to_sym]) do |system_locale|
      system_locale.title = I18n.t('anubis.install.system_title')
    end
  end

  ##
  # Create default tenant with id 1
  tenant = Anubis::Tenant::Tenant.find_by_id(1)
  tenant = Anubis::Tenant::Tenant.create(id: 1, title: I18n.t('anubis.install.tenant_title'), state: Anubis::Tenant::Tenant.states[:default]) if !tenant

  Anubis::Tenant::TenantSystem.find_or_create_by tenant: tenant, system: system

  ##
  # Load Administrator group of Main System
  admin_group = Anubis::Tenant::Group.where(system: system, ident: 'admin').first
  I18n.available_locales.each do |locale|
    I18n.locale = locale
    Anubis::Tenant::GroupLocale.find_or_create_by(group_id: admin_group.id, locale: Anubis::Tenant::GroupLocale.locales[locale.to_s.to_sym]) do |group_locale|
      group_locale.title = I18n.t('anubis.install.admins_group')
    end
  end

  ##
  # Create main administrator with id 1
  admin_user = Anubis::Tenant::User.find_by_id(1)
  admin_user = Anubis::Tenant::User.create(id: 1, email: 'admin@local.local', name: I18n.t('anubis.install.admin_name'), surname: I18n.t('anubis.install.admin_surname'), timezone: 'GMT', status: 0, tenant: tenant) if !admin_user

  Anubis::Tenant::UserGroup.find_or_create_by(user_id: admin_user.id, group_id: admin_group.id)

  menu_0 = create_menu({ mode: 'anubis/admin', action: 'menu' })
  menu_1 = create_menu({ mode: 'anubis/tenants', action: 'data', parent: menu_0, system: system, group: admin_group, access: 'write' })
  menu_1 = create_menu({ mode: 'anubis/users', action: 'data', parent: menu_0, system: system, group: admin_group, access: 'write' })
end