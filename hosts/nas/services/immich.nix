{ pkgs, ... }:

{
  # ---- Immich (docker; ML disabled — N5095 has no AVX, onnxruntime would SIGILL) ----
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    immich-server = {
      image = "ghcr.io/immich-app/immich-server:release";
      ports = [ "2283:2283" ];
      volumes = [
        "/srv/immich/library:/usr/src/app/upload"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        IMMICH_VERSION = "release";
        DB_HOSTNAME = "immich-db";
        DB_USERNAME = "immich";
        DB_PASSWORD = "immich";
        DB_DATABASE_NAME = "immich";
        REDIS_HOSTNAME = "immich-redis";
        IMMICH_MACHINE_LEARNING_ENABLED = "false";
      };
      extraOptions = [ "--network=immich" ];
      autoStart = false;
    };
    immich-redis = {
      image = "docker.io/library/redis:6.2-alpine";
      extraOptions = [ "--network=immich" ];
      autoStart = false;
    };
    immich-db = {
      image = "ghcr.io/immich-app/postgres:16-vectorchord0.4.3-pgvectors0.2.0";
      environment = {
        POSTGRES_PASSWORD = "immich";
        POSTGRES_USER = "immich";
        POSTGRES_DB = "immich";
      };
      volumes = [
        "/srv/immich/db:/var/lib/postgresql/data"
      ];
      extraOptions = [ "--network=immich" ];
      autoStart = false;
    };
  };
  # ordering for the immich trio (docker run has no --depends-on; that's compose-only)
  systemd.services.docker-immich-network = {
    description = "Ensure docker network 'immich' exists";
    after = [ "docker.service" ];
    wantedBy = [ "docker-immich-db.service" "docker-immich-redis.service" ];
    before = [ "docker-immich-db.service" "docker-immich-redis.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.docker}/bin/docker network create immich || true";
      RemainAfterExit = true;
    };
  };
  systemd.services.docker-immich-db = {
    after = [ "docker-immich-network.service" ];
    wants = [ "docker-immich-network.service" ];
  };
  systemd.services.docker-immich-redis = {
    after = [ "docker-immich-network.service" ];
    wants = [ "docker-immich-network.service" ];
  };
  systemd.services.docker-immich-server = {
    after = [ "docker-immich-db.service" "docker-immich-redis.service" "docker-immich-network.service" ];
    wants = [ "docker-immich-db.service" "docker-immich-redis.service" ];
  };

}
