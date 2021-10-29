# frozen_string_literal: true

require "ci_toolkit"
require "rspec"

describe CiToolkit::GithubBot do
  # fake private key
  private_key = "-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAqfsTpaBdjbZAaWbSKZBFj/5iR0k+bLJrREJbmYWMtMXrHjPi
LUlyIxzeeu/3t+aeO7/CNbS/MKn0qa90+i9gDGVR+Ir3HZOH4IWil3gK5tFon7nf
u32x2TBU0mXDQxIHL4S8x4tM1o43BfLWrDLFCuQVJ5HrSYgFL/ox1VkYrB8QM6if
spXKdYo4rEJNNg1E9iZbt9GPCcdMYjFO8l5tAWrCRsMWGnoB3cVc8wpt8nYkirR2
ZbTtrNs83htoDqlW1RNKP8o7EMdy8Qr/VmfIL4d7xOlWN1UeTrVZHPcICNhqhw4s
dDJSMLxafJIsxgKurBTT0+K0z3d+CUct2Mn/pQIDAQABAoIBAGhjF5q0VB+uF/pi
uZfq0L1wNHygv2RTYcqGkehC+rkdfpmKtVCodR6ZIQwQiGl4iB4bUjJXML668NSw
Or+4AiG6q09eUAnqyxwYFVS91LwRSBYnOP3UYD8IDl8zPWnYDW+iLajBpEtzBNlz
W2BewWFB1rf5Raxfiwf+t1HVKHCylk2bWsAyCIOFFP+iNiloaPrNjTcD3iKvNwoE
XOMRUa15Wo23SK1h1ulWJasfYOLdTRMTsZ/yrZJGt5iWruHlr7Yrjcnr3+Q+HWLs
HtoM8pIV2cLXQrzAdKKHckxmfdTIR0uGasbfH9ss5jWJnyJNAuB6DF0mXd7znHXw
bBzhBqECgYEA3IKrpiLJc/X7p9tlGEz7dKOqC4pmEZnjCUBjF2jC4Zx3i4AhJ1BH
jKkg7nEKeNJZdixuqZdV4lbETq+H4pzdoSl4+93QXKx6mzPBM2rNP6OYtPOcSut0
X7/fXxgF953AIB+B09Y/aEWnbKfMMG3bBeZ3Ol7j9pRmqEpzInAyfqkCgYEAxVaD
9BaGqhS8zGlKhfryKQvsN58V4UwCMpLYglsg5G7cH9a1BnDtbEysOTjqMosD+Fjv
/usOYxON+N2yqQ30R+Q7B3hplvKJ4fEX10RK38VfrI/+ynSCTEMhSEa4HxjefyLZ
D5gUHLGr4rdX6L241dQETtiYnx5P7kGS3axNAp0CgYByfjZ5sJ5A43ujEDtRfsch
LMlh7J5KjUhgyVmqEe7+DavUdta//uLnmflLVM5HJZDl1vQugjFJsBuFb4Zyl1hM
EaiLvgQt2jBe3WR3OgEQBfWIHuUL0W0/OfTU/zg59WKIS1OxlhCeJ2xi8k0G6ENM
sPk9OEXNBgi3YNCfFPpi4QKBgCRo/he/QEGJafxdQP7PenbQWFk65RKYr58dMQ18
Oulq+vp05xm1JFljHDPCqJOCysy7vCxQumrVZNCSNzCx/mx1U97g/Lp5La+eiEOT
uizngeuY9e3s6U2g5TcstTQnpoXWrC4QZUWWEpzWL0YmG0B4ygKyPBa/xQe02aBE
9kCRAoGAfJCqLwMG4EqoNSBYMGnTFkeUMxcW2R/RXkXwu74u/SXFlJ5FTZbvlHvP
NpU1l9VZFzCUwY/0iX2SI8P2rysvPNn769RMeUjn3R1DQ8TU157ztaGaH+AQiBJZ
swIsgsgtI0KZa85gyHsfadtSVXPhinUzxymz17sicnY5nGRGTj0=
-----END RSA PRIVATE KEY-----"
  creds = CiToolkit::GithubBot::Credentials.new(123)

  it "provides a valid token" do
    client = instance_spy("client")
    allow(client).to receive(:create_app_installation_access_token).and_return({ token: "23fdasfk43kjkk" })

    sut = described_class.new(creds, client)
    expect(sut.create_token).to eq "23fdasfk43kjkk"
  end

  it "finds the app installation" do
    client = instance_spy("client")
    allow(client).to receive(:find_app_installations).and_return([{ app_id: 123 }])

    described_class.new(creds, client).create_token
    expect(client).to have_received(:find_app_installations)
  end

  it "creates a valid jwt token" do
    sut = CiToolkit::GithubBot::Credentials.new(123, private_key)
    expect(sut.jwt_token).not_to be_nil
  end
end
