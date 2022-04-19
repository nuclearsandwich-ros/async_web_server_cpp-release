%bcond_without tests
%bcond_without weak_deps

%global __os_install_post %(echo '%{__os_install_post}' | sed -e 's!/usr/lib[^[:space:]]*/brp-python-bytecompile[[:space:]].*$!!g')
%global __provides_exclude_from ^@(InstallationPrefix)/.*$
%global __requires_exclude_from ^@(InstallationPrefix)/.*$

Name:           @(Package)
Version:        @(Version)
Release:        @(RPMInc)%{?dist}%{?release_suffix}
Summary:        ROS @(Name) package

License:        @(License)
@[if Homepage and Homepage != '']URL:            @(Homepage)@\n@[end if]@
Source0:        %{name}-%{version}.tar.gz
@[if NoArch]@\nBuildArch:      noarch@\n@[end if]@

@[for p in Depends]Requires:       @p@\n@[end for]@
@[for p in BuildDepends]BuildRequires:  @p@\n@[end for]@
@[for p in Conflicts]Conflicts:      @p@\n@[end for]@
@[for p in Replaces]Obsoletes:      @p@\n@[end for]@
@[for p in Provides]Provides:       @p@\n@[end for]@
@[if TestDepends]@\n%if 0%{?with_tests}
@[for p in TestDepends]BuildRequires:  @p@\n@[end for]@
%endif@\n@[end if]@
@[if Supplements]@\n%if 0%{?with_weak_deps}
@[for p in Supplements]Supplements:    @p@\n@[end for]@
%endif@\n@[end if]@

%description
@(Description)

%prep
%autosetup -p1

%build
# In case we're installing to a non-standard location, look for a setup.sh
# in the install tree that was dropped by catkin, and source it.  It will
# set things like CMAKE_PREFIX_PATH, PKG_CONFIG_PATH, and PYTHONPATH.
if [ -f "@(InstallationPrefix)/setup.sh" ]; then . "@(InstallationPrefix)/setup.sh"; fi
mkdir -p .obj-%{_target_platform} && cd .obj-%{_target_platform}
%cmake3 \
    -UINCLUDE_INSTALL_DIR \
    -ULIB_INSTALL_DIR \
    -USYSCONF_INSTALL_DIR \
    -USHARE_INSTALL_PREFIX \
    -ULIB_SUFFIX \
    -DCMAKE_INSTALL_PREFIX="@(InstallationPrefix)" \
    -DCMAKE_PREFIX_PATH="@(InstallationPrefix)" \
    -DSETUPTOOLS_DEB_LAYOUT=OFF \
    -DCATKIN_BUILD_BINARY_PACKAGE="1" \
%if !0%{?with_tests}
    -DBUILD_TESTING=OFF \
    -DCATKIN_ENABLE_TESTING=OFF \
%endif
    ..

%make_build

%install
# In case we're installing to a non-standard location, look for a setup.sh
# in the install tree that was dropped by catkin, and source it.  It will
# set things like CMAKE_PREFIX_PATH, PKG_CONFIG_PATH, and PYTHONPATH.
if [ -f "@(InstallationPrefix)/setup.sh" ]; then . "@(InstallationPrefix)/setup.sh"; fi
%make_install -C .obj-%{_target_platform}

%files
@[for lf in LicenseFiles]%license @lf@\n@[end for]@
@(InstallationPrefix)

%changelog@
@[for change_version, (change_date, main_name, main_email) in changelogs]
* @(change_date) @(main_name) <@(main_email)> - @(change_version)
- Autogenerated by Bloom
@[end for]
