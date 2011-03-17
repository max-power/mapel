require File.dirname(__FILE__) + '/spec_helper.rb'

describe Mapel do
  before {setup}
  after {teardown}

  it "should respond to #info" do
    Mapel.respond_to?(:info).should == true
  end

  it "should respond to #render" do
    Mapel.respond_to?(:render).should == true
  end

  it "should support compact rendering syntax" do
    Mapel(logo).should.be.kind_of(Mapel::Engine)
  end

  describe "#info" do
    it "should return basic image metadata" do
      info = Mapel.info(logo)
      info[:path].should == logo
      info[:format].should == 'JPEG'
      info[:dimensions].should == [572, 591]
      info[:depth].should == '8-bit'
      ["95.1kb", "97.4KB"].include?(info[:size]).should == true
    end

    it "should return an empty hash if metadata can not be extracted" do
      Mapel.info("invalid.jpg").should == {}
    end
  end

  describe "#render" do
    it "should be able to scale an image" do
      cmd = Mapel(logo).scale('50%').to(out_folder + '/scaled.jpg').run
      cmd.status.should == true
      Mapel.info(out_folder + '/scaled.jpg')[:dimensions].should == [286, 296]
    end

    it "should be able to crop an image" do
      cmd = Mapel(logo).crop('50x50+0+0').to(out_folder + '/cropped.jpg').run
      cmd.status.should == true
      Mapel.info(out_folder + '/cropped.jpg')[:dimensions].should == [50, 50]
    end

    it "should be able to resize an image" do
      cmd = Mapel(logo).resize('100x').to(out_folder + '/resized.jpg').run
      cmd.status.should == true
      Mapel.info(out_folder + '/resized.jpg')[:dimensions].should == [100, 103]
    end

    it "should be able to crop-resize an image" do
      cmd = Mapel(logo).gravity(:west).resize!('50x100').to(out_folder + '/crop_resized.jpg').run
      cmd.status.should == true
      Mapel.info(out_folder + '/crop_resized.jpg')[:dimensions].should == [50, 100]
    end

    it "should allow arbitrary addition of commands to the queue" do
      cmd = Mapel(logo).gravity(:west)
      cmd.resize(50, 50)
      cmd.to_preview.should == %(convert #{logo} -gravity west -resize "50x50")
    end
  end
end