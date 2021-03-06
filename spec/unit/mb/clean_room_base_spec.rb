require 'spec_helper'

describe MB::CleanRoomBase do
  let(:real_model) { double('real_model') }
  let(:block) { double('block') }

  describe "ClassMethods" do
    subject { MB::CleanRoomBase }

    describe "::dsl_attr_writer" do
      it "creates a function of the given name on the instance of clean room" do
        subject.dsl_attr_writer :name

        subject.new(real_model) do
          # block
        end.should respond_to(:name)
      end

      it "assigns the value from the generated function to the real_model" do
        value = double('value')
        subject.dsl_attr_writer :name

        real_model.should_receive(:name=).with(value)

        subject.new(real_model) do
          # block
        end.name(value)
      end
    end
  end
end
