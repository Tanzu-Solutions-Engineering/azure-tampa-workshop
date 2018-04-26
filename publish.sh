git pull
./gradlew build -xcheckLinks
cf push spring-bootcamp -p build/site/ -b staticfile_buildpack
