require 'spec_helper'

describe Collaboratorship do
  let(:collaboratorship) { FactoryGirl.create(:user_project_collaboration) }

  describe "Validations" do
    it "is valid" do
      expect(collaboratorship).to be_valid
    end

    it "is invalid without a collaborator" do
      collaboratorship.collaborator = nil
      expect(collaboratorship).to_not be_valid
    end

    it "is invalid without a collaboratable" do
      collaboratorship.collaboratable = nil
      expect(collaboratorship).to_not be_valid
    end

    it "is invalid without a role" do
      collaboratorship.role = nil
      expect(collaboratorship).to_not be_valid
    end

    it "is invalid without a state" do
      collaboratorship.state = nil
      expect(collaboratorship).to_not be_valid
    end
  end

  describe "Defaults" do
    it "defaults role to member" do
      expect(collaboratorship.role).to eql("member")
    end

    it "defaults state to pending" do
      expect(collaboratorship.state).to eql("pending")
    end
  end
end
