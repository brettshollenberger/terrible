require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.create(:user) }

  describe "Validations" do
    it "is valid" do
      expect(user).to be_valid
    end

    it "is invalid without a first name" do
      user.first = nil
      expect(user).to_not be_valid
    end

    it "is invalid without a last name" do
      user.last = nil
      expect(user).to_not be_valid
    end
  end
end
