#!/bin/bash

# Define the base project directory
PROJECT_DIR="real-time-streaming-project"

# Stop and remove all containers related to the project
docker-compose -f $PROJECT_DIR/docker-compose.yml down

# Remove all Docker images related to the project
docker rmi real-time-streaming-project-kafka real-time-streaming-project-producer real-time-streaming-project-consumer real-time-streaming-project-processor -f

# Remove the project directory and all its content
if [ -d "$PROJECT_DIR" ]; then
    rm -rf "$PROJECT_DIR"
    echo "$PROJECT_DIR and its contents have been deleted."
else
    echo "$PROJECT_DIR does not exist."
fi

# Remove dangling images, stopped containers, and other unused resources (optional)
docker system prune -f

echo "Cleanup complete."
#!/bin/bash

# Define the base project directory
PROJECT_DIR="real-time-streaming-project"

# Function to stop and remove containers
cleanup_containers() {
    docker-compose -f $PROJECT_DIR/docker-compose.yml down
}

# Function to remove Docker images
cleanup_images() {
    docker rmi real-time-streaming-project-kafka real-time-streaming-project-producer real-time-streaming-project-consumer real-time-streaming-project-processor -f
}

# Function to remove the project directory
cleanup_project_structure() {
    if [ -d "$PROJECT_DIR" ]; then
        rm -rf "$PROJECT_DIR"
        echo "$PROJECT_DIR and its contents have been deleted."
    else
        echo "$PROJECT_DIR does not exist."
    fi
}

# Function to prune Docker system (optional)
prune_docker_system() {
    docker system prune -f
}

# Function to show usage
usage() {
    echo "Usage: $0 [--full | --structure-only]"
    echo "  --full          : Remove containers, images, and project structure."
    echo "  --structure-only: Remove only the project structure without touching Docker images."
    exit 1
}

# Check if the script received an argument
if [ "$#" -eq 0 ]; then
    usage
fi

# Process the command-line arguments
case "$1" in
    --full)
        cleanup_containers
        cleanup_images
        cleanup_project_structure
        prune_docker_system
        echo "Full cleanup complete."
        ;;
    --structure-only)
        cleanup_project_structure
        echo "Project structure cleanup complete."
        ;;
    *)
        usage
        ;;
esac
