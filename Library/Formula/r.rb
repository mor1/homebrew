require 'formula'

def valgrind?
  ARGV.include? '--with-valgrind'
end

class RBashCompletion < Formula
  # This is the same script that Debian packages use.
  url 'http://rcompletion.googlecode.com/svn-history/r12/trunk/bash_completion/R', :using => :curl
  version 'r12'
  md5 '3c8f6cf1c07e052074ee843be00fa5d6'
end

class R < Formula
  homepage 'http://www.r-project.org'
  url 'http://cran.r-project.org/src/base/R-2/R-2.14.1.tar.gz'
  md5 'ba5b6fb15b660670ea29b885348f322a'

  depends_on 'valgrind' if valgrind?
  depends_on 'readline'

  def options
    [
      ['--with-valgrind', 'Compile an unoptimized build with support for the Valgrind debugger.']
    ]
  end

  def install
    unless `/usr/bin/which gfortran`.chomp.size > 0
      opoo 'No gfortran found in path'
      puts "You'll need to `brew install gfortran` or otherwise have a copy"
      puts "of gfortran in your path for this brew to work."
    end

    ENV["FCFLAGS"] = ENV["CFLAGS"]
    ENV["FFLAGS"]  = ENV["CFLAGS"]

    system "./configure", "--prefix=#{prefix}", "--with-aqua", "--enable-R-framework",
           "--with-lapack"
    system "make"
    ENV.j1 # Serialized installs, please
    system "make install"

    # Link binaries and manpages from the Framework
    # into the normal locations
    bin.mkpath
    man1.mkpath

    ln_s prefix+"R.framework/Resources/bin/R", bin
    ln_s prefix+"R.framework/Resources/bin/Rscript", bin
    ln_s prefix+"R.framework/Resources/man1/R.1", man1
    ln_s prefix+"R.framework/Resources/man1/Rscript.1", man1
  end
end
