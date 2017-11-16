# This custom formula is edited to support verison 9.6 of PostgreSQL.

class Postgis < Formula
  desc "Adds support for geographic objects to PostgreSQL"
  homepage "https://postgis.net/"
  url "http://download.osgeo.org/postgis/source/postgis-2.4.0.tar.gz"
  sha256 "02baa90f04da41e04b6c18eedfda53110c45ae943d4e65050f6d202f7de07d29"
  revision 1

  head do
    url "https://svn.osgeo.org/postgis/trunk/"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "gpp" => :build
  depends_on "postgresql@9.6"
  depends_on "proj"
  depends_on "geos"

  depends_on "gdal" => :recommended
  depends_on "pcre" if build.with? "gdal"

  def install
    ENV.deparallelize

    args = [
      "--with-projdir=#{Formula["proj"].opt_prefix}",
      "--with-pgconfig=#{Formula["postgresql@9.6"].opt_bin}/pg_config",
    ]

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make"

    mkdir "stage"
    system "make", "install", "DESTDIR=#{buildpath}/stage"

    bin.install Dir["stage/**/bin/*"]
    lib.install Dir["stage/**/lib/*"]
    include.install Dir["stage/**/include/*"]
    (doc/"postgresql@9.6/extension").install Dir["stage/**/share/doc/postgresql@9.6/extension/*"]
    (share/"postgresql@9.6/extension").install Dir["stage/**/share/postgresql@9.6/extension/*"]
    pkgshare.install Dir["stage/**/contrib/postgis-*/*"]
    (share/"postgis_topology").install Dir["stage/**/contrib/postgis_topology-*/*"]

    # Extension scripts
    bin.install %w[
      utils/create_undef.pl
      utils/postgis_proc_upgrade.pl
      utils/postgis_restore.pl
      utils/profile_intersects.pl
      utils/test_estimation.pl
      utils/test_geography_estimation.pl
      utils/test_geography_joinestimation.pl
      utils/test_joinestimation.pl
    ]

    man1.install Dir["doc/**/*.1"]
  end
end
