dnf install -y tox git python3-build python3-hatchling
git clone https://github.com/huakim/py2pack.git
. ./generate_sources.sh
rpmbuild "-D_srcrpmdir ${outdir}" "-D_sourcedir ${outdir}" --bs "${outdir}/python-py2pack.spec"

