if [ -z "$outdir" ]; then
  outdir='.'
fi

echo "outdir: '$outdir'"
outdir=`realpath $outdir`

pushd *py2pack
python3 -m build -o "$outdir" -n -s
if [[ ! -f "${outdir}/python-py2pack.spec" ]]
then
  tox -e generate
  (
     cat << EOF
Epoch: 3
EOF
     cat "python-py2pack.spec" | sed 's~\(%package -n %{python_name}\)~\1\nRequires: py2pack-base-templates~ ; s~%install~%install\n mkdir -pv %{buildroot}%{_datadir}/py2pack/templates \n mv py2pack/templates/* %{buildroot}%{_datadir}/py2pack/templates\n~'
     cat << EOF

%package -n py2pack-base-templates
Summary: base templates

%description -n py2pack-base-templates
base templates.

%files -n py2pack-base-templates
%dir %{_datadir}/py2pack
%dir %{_datadir}/py2pack/templates
%{_datadir}/py2pack/templates/*

EOF
  ) > "${outdir}/python-py2pack.spec"
fi
popd


ver="$(tar --wildcards -xzOf "$outdir"/py2pack-*.tar.gz py2pack-*/PKG-INFO | grep '^Version:' | sed 's/Version:\s*//')"

gunzip "${outdir}/py2pack-${ver}.tar.gz"
ln -s py2pack "py2pack-${ver}"
tar rf "${outdir}/py2pack-${ver}.tar" "py2pack-${ver}/py2pack/templates/"*
tar --delete -f "${outdir}/py2pack-${ver}.tar" "py2pack-${ver}/test/"
gzip "${outdir}/py2pack-${ver}.tar"

echo "Version: $ver" | tee "$outdir"/PKGINFO

