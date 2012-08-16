Name:       swig
Summary:    Connects C/C++/Objective C to some high-level programming languages
Version:    1.3.40
Release:    1
Group:      Development/Tools
License:    BSD
URL:        http://swig.sourceforge.net
Source0:    %{name}-%{version}.tar.gz
Source1:    swig-rpmlintrc
Patch0:     swig-1.3.23-pylib.patch
BuildRequires:  perl
BuildRequires:  python-devel

%description
SWIG is a software development tool that connects programs written in C
and C++ with a variety of high-level programming languages. SWIG is 
primarily used with common scripting languages such as Perl, PHP, Python,
Tcl/Tk, and Ruby, however the list of supported languages also includes
non-scripting languages such as C#, Common Lisp (CLISP, Allegro CL, UFFI),
Java, Modula-3, OCAML, Octave, and R. Also several interpreted and compiled
Scheme implementations (Guile, MzScheme, Chicken) are supported. SWIG is 
most commonly used to create high-level interpreted or compiled programming 
environments, user interfaces, and as a tool for testing and prototyping C/C++
software. SWIG can also export its parse tree in the form of XML and Lisp
s-expressions.



%package doc
Summary:    Documentation files for %{name}
Group:      Documentation
Requires:   %{name} = %{version}-%{release}

%description doc
Description: %{summary}


%prep
%setup -q -n %{name}-%{version}

%patch0 -p1

%build
%configure --disable-static
make %{?jobs:-j%jobs}

%install
rm -rf %{buildroot}
%make_install

%files
%defattr(-,root,root,-)
%doc LICENSE
%{_bindir}/*
%{_datadir}/swig
/usr/share/man/man1/ccache-swig.1.gz


%files doc
%defattr(-,root,root,-)
%doc ANNOUNCE CHANGES FUTURE INSTALL NEW README TODO
%doc Doc/*
