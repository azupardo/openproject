#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

class AuthProvider < ApplicationRecord
  belongs_to :creator, class_name: "User"

  validates :display_name, presence: true
  validates :display_name, uniqueness: true

  after_destroy :unset_direct_provider

  def self.slug_fragment
    raise NotImplementedError
  end

  def user_count
    @user_count ||= User.where("identity_url LIKE ?", "#{slug}%").count
  end

  def human_type
    raise NotImplementedError
  end

  def auth_url
    root_url = OpenProject::StaticRouting::StaticUrlHelpers.new.root_url
    URI.join(root_url, "auth/#{slug}/").to_s
  end

  def callback_url
    URI.join(auth_url, "callback").to_s
  end

  protected

  def unset_direct_provider
    if Setting.omniauth_direct_login_provider == slug
      Setting.omniauth_direct_login_provider = ""
    end
  end
end
