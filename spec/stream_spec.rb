require 'spec_helper'

describe "stream" do
  it "should respond to basic methods" do
    expect(Stream.decode("gi8ASGI2N2Q4NjJiLTJiMzItNDQ1YS1iYzgzLWRkNTI1Y2UzMGFlOQAITllQTAAcMzM0MzMwMDU0ODY2MDQAHjIzNDU2Nzg5MDk4NzY1NAIAfkxlIHJlbGF6aW9uaSBkaXBsb21hdGljaGUgZnJhIGwnQXVzdHJpYSBlIGlsIFJlZ25vIGRpIFNhcmRlZ25hLgAAAB5KRk0gODEtNzggIHYuIDICADIyMDE3LTA2LTI4VDE2OjU2OjIxLTA0OjAw")).to_not be_nil
    expect(Stream.encode({ "jobId" => "123", "success" => true, "holdRequestId" => 12345 })).to_not be_nil
  end
end
