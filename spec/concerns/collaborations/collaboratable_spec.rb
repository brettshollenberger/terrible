require "spec_helper"

describe Collaborations::Collaboratable do
  let(:collaboratorship)         { FactoryGirl.create(:user_project_collaboration) }
  let(:user)                     { collaboratorship.collaborator }
  let(:pending_collaboratorship) { FactoryGirl.create(:pending_user_project_collaboration,
                                                      collaborator: user) }
  let(:ownership)                { FactoryGirl.create(:user_project_ownership,
                                                      collaborator: user) }
  let(:project)                  { collaboratorship.collaboratable }
  let(:pending_project)          { pending_collaboratorship.collaboratable }
  let(:owned_project)            { ownership.collaboratable }

  it "" do
  end
end
