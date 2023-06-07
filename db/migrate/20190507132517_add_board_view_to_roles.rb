require "#{Rails.root}/db/migrate/migration_utils/permission_adder"

class AddBoardViewToRoles < ActiveRecord::Migration[5.2]
  def up
    ::Migration::MigrationUtils::PermissionAdder
      .add(:view_work_packages,
           :show_board_views)

    # Reset the colum information and the instance variable cached in the has_updated_at_column? method.
    # On saas, the migrations are ran at the public schema first, then on the remaining tenants.
    # This happens in the same process and the has_updated_at_column? remains cached from the first
    # migration run. When the tenants are migrated, the `has_updated_at_column?` has a stale cached value
    # and it causes an error. See https://community.openproject.org/wp/48454 .
    Setting.reset_column_information
    Setting.instance_variable_set(:@has_updated_at_column, nil)

    unless Setting.default_projects_modules.include?('board_view')
      Setting.default_projects_modules = Setting.default_projects_modules + ['board_view']
    end
  end

  def down
    # Nothing to do
  end
end
