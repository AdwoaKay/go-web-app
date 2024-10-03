FROM golang:1.22.5 AS base

WORKDIR /app

# Copy go.mod and download dependencies
COPY go.mod .

RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the Go application for Linux
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .

# Reduce the image size using multi-stage builds
# We will use a distroless image to run the application
# Use a minimal distroless image for final deployment
FROM gcr.io/distroless/base

# Copy the binary and static files from the builder stage
COPY --from=base /app/main .
COPY --from=base /app/static ./static

# Expose the port your app will use
EXPOSE 8080

# Set the command to run your app
CMD ["./main"]
