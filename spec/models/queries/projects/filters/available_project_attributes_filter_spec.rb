#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2012-2024 the OpenProject GmbH
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

require "spec_helper"

RSpec.describe Queries::Projects::Filters::AvailableProjectAttributesFilter do
  it_behaves_like "basic query filter" do
    let(:class_key) { :available_project_attributes }
    let(:type) { :list }
    let(:human_name) { "Available project attributes" }
  end

  it_behaves_like "list query filter", scope: false do
    let(:project_custom_field_project_mapping1) { build_stubbed(:project_custom_field_project_mapping) }
    let(:project_custom_field_project_mapping2) { build_stubbed(:project_custom_field_project_mapping) }
    let(:valid_values) { [project_custom_field_project_mapping1.id, project_custom_field_project_mapping2.id] }
    let(:name) { "Available project attributes" }

    before do
      allow(ProjectCustomFieldProjectMapping)
        .to receive(:pluck)
        .with(:custom_field_id)
        .and_return([project_custom_field_project_mapping1.id,
                     project_custom_field_project_mapping2.id])
    end

    describe "#scope" do
      let(:values) { valid_values }

      let(:project_custom_field_project_mapping_handwritten_sql_subquery) do
        <<-SQL.squish
            SELECT DISTINCT "project_custom_field_project_mappings"."project_id"
              FROM "project_custom_field_project_mappings"
              WHERE "project_custom_field_project_mappings"."custom_field_id"
              IN (#{values.join(', ')})
        SQL
      end

      context 'for "="' do
        let(:operator) { "=" }

        it "is the same as handwriting the query" do
          handwritten_scope_sql = <<-SQL.squish
            SELECT "projects".* FROM "projects"
              WHERE "projects"."id" IN (#{project_custom_field_project_mapping_handwritten_sql_subquery})
          SQL

          expect(instance.scope.to_sql).to eql handwritten_scope_sql
        end
      end

      context 'for "!"' do
        let(:operator) { "!" }

        it "is the same as handwriting the query" do
          handwritten_scope_sql = <<-SQL.squish
            SELECT "projects".* FROM "projects"
              WHERE "projects"."id" NOT IN (#{project_custom_field_project_mapping_handwritten_sql_subquery})
          SQL

          expect(instance.scope.to_sql).to eql handwritten_scope_sql
        end
      end

      context "for an unsupported operator" do
        let(:operator) { "!=" }

        it "raises an error" do
          expect { instance.scope }.to raise_error("unsupported operator")
        end
      end
    end

    describe "#allowed_values" do
      it "is a list of the possible values" do
        expected = [[project_custom_field_project_mapping1.id, project_custom_field_project_mapping1.id.to_s],
                    [project_custom_field_project_mapping2.id, project_custom_field_project_mapping2.id.to_s]]

        expect(instance.allowed_values).to match_array(expected)
      end
    end
  end
end
