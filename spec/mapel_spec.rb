require File.dirname(__FILE__) + "/spec_helper.rb"

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
      info[:format].should == "JPEG"
      info[:dimensions].should == [572, 591]
      info[:depth].should == "8-bit"
      ["95.1kb", "97.4KB"].include?(info[:size]).should == true # allow KB and KiB
    end

    it "should return an empty hash if metadata can not be extracted" do
      Mapel.info("invalid.jpg").should == {}
    end

    it "should be able to read files with spaces in the filename" do
      Mapel.info(multi_word_file)[:path].should == multi_word_file
    end
  end

  describe "#exif" do
    it "should return EXIF image data" do
      exif = Mapel.exif(rotated_image)
      exif["ExifImageWidth"].should == "200"
      exif["ExifImageLength"].should == "194"
      exif["XResolution"].should == "3000000/10000"
      exif["YResolution"].should == "3000000/10000"
      exif["ResolutionUnit"].should == "2"
      exif["ColorSpace"].should == "65535"
      exif["ExifOffset"].should == "164"
      exif["Orientation"].should == "6"
      exif["Compression"].should == "6"
      exif["JPEGInterchangeFormatLength"].should == "7072"
      exif["JPEGInterchangeFormat"].should == "302"
      exif["DateTime"].should == "2011:06:28 10:40:20"
      exif["Software"].should == "Adobe Photoshop CS3 Macintosh"
    end
  end

  describe "#render" do
    it "should be able to scale an image" do
      out_file = "#{out_folder}/scaled.jpg"
      cmd = Mapel(logo).scale("50%").to(out_file).run
      cmd.status.should == true
      Mapel.info(out_file)[:dimensions].should == [286, 296]
    end

    it "should be able to crop an image" do
      out_file = "#{out_folder}/cropped.jpg"
      cmd = Mapel(logo).crop("50x50+0+0").to(out_file).run
      cmd.status.should == true
      Mapel.info(out_file)[:dimensions].should == [50, 50]
    end

    it "should be able to resize an image" do
      out_file = "#{out_folder}/cropped.jpg"
      cmd = Mapel(logo).resize("100x").to(out_file).run
      cmd.status.should == true
      Mapel.info(out_file)[:dimensions].should == [100, 103]
    end

    it "should be able to crop-resize an image" do
      out_file = "#{out_folder}/crop_resized.jpg"
      cmd = Mapel(logo).gravity(:west).resize!("50x100").to(out_file).run
      cmd.status.should == true
      Mapel.info(out_file)[:dimensions].should == [50, 100]
    end

    it "should allow arbitrary addition of commands to the queue" do
      cmd = Mapel(logo).gravity(:west)
      cmd.resize(50, 50)
      cmd.to_preview.should == %(convert "#{logo}" -gravity west -resize "50x50")
    end

    it "should allow stripping additional image metadata" do
      cmd = Mapel(logo).strip.resize(50, 50)
      cmd.to_preview.should == %(convert "#{logo}" -strip -resize "50x50")
    end

    it "should be able to handle input filenames containing spaces" do
      out_file = "#{out_folder}/resized.jpg"
      cmd = Mapel(multi_word_file).resize("100x").to(out_file).run
      cmd.status.should == true
      Mapel.info(out_file)[:dimensions].should == [100, 103]
    end

    it "should be able to handle output filenames containing spaces" do
      out_file = "#{out_folder}/multi-word file.jpg"
      cmd = Mapel(@logo).resize("100x").to(out_file).run
      cmd.status.should == true
      Mapel.info(out_file)[:dimensions].should == [100, 103]
    end
  end
end
