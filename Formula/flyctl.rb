class Flyctl < Formula
  desc "Command-line tools for fly.io services"
  homepage "https://fly.io"
  url "https://github.com/superfly/flyctl.git",
      tag:      "v0.0.357",
      revision: "bf83260b9931b2bc271c08bca2956b342bded318"
  license "Apache-2.0"
  head "https://github.com/superfly/flyctl.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "c7147abcd6b6ee96ee00053a451a8d023fb41ddd2c93058b0555b7b0655dabc8"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "c7147abcd6b6ee96ee00053a451a8d023fb41ddd2c93058b0555b7b0655dabc8"
    sha256 cellar: :any_skip_relocation, monterey:       "23906ea17eea60025d561a483182328b8528b283cfd7f4c53500d63bcab69f85"
    sha256 cellar: :any_skip_relocation, big_sur:        "23906ea17eea60025d561a483182328b8528b283cfd7f4c53500d63bcab69f85"
    sha256 cellar: :any_skip_relocation, catalina:       "23906ea17eea60025d561a483182328b8528b283cfd7f4c53500d63bcab69f85"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "eb24868e78d33084cb8ab77be56efbcd985ca80ce96292f7fee72053749a98e6"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/superfly/flyctl/internal/buildinfo.environment=production
      -X github.com/superfly/flyctl/internal/buildinfo.buildDate=#{time.iso8601}
      -X github.com/superfly/flyctl/internal/buildinfo.version=#{version}
      -X github.com/superfly/flyctl/internal/buildinfo.commit=#{Utils.git_short_head}
    ]
    system "go", "build", *std_go_args(ldflags: ldflags)

    bin.install_symlink "flyctl" => "fly"

    bash_output = Utils.safe_popen_read("#{bin}/flyctl", "completion", "bash")
    (bash_completion/"flyctl").write bash_output
    zsh_output = Utils.safe_popen_read("#{bin}/flyctl", "completion", "zsh")
    (zsh_completion/"_flyctl").write zsh_output
    fish_output = Utils.safe_popen_read("#{bin}/flyctl", "completion", "fish")
    (fish_completion/"flyctl.fish").write fish_output
  end

  test do
    assert_match "flyctl v#{version}", shell_output("#{bin}/flyctl version")

    flyctl_status = shell_output("flyctl status 2>&1", 1)
    assert_match "Error No access token available. Please login with 'flyctl auth login'", flyctl_status
  end
end
