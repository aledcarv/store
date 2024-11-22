# Store

API for managing an e-commerce shopping cart.

### Environment variables setup

```bash
$ cp .env.example .env
```

### Building and running the _container_ in interactive mode

```bash
$ docker-compose build

$ docker-compose run --rm --service-ports web bash
```

### Database setup

```bash
$ bin/rails db:create
$ bin/rails db:migrate
```

### Running the Server

```bash
$ bin/rails s -b 0.0.0.0
```

### Running the tests

```bash
$ bundle exec rspec
```

### Background Jobs

This application uses Sidekiq for processing background jobs:

#### Setup

Start Sidekiq worker: `bundle exec sidekiq`

#### Monitoring

Access Sidekiq dashboard at `/sidekiq`

## API

### View available products

#### GET /products

- response:

```bash
[
    {
        "id": 203,
        "name": "Product A",
        "price": "10.0",
        "created_at": "2024-11-22T02:23:30.895Z",
        "updated_at": "2024-11-22T02:23:30.895Z"
    }
]
```

---

### Create a product

#### POST /products

- params:

```bash
{
    "name": "Product A",
    "price": 10.0
}
```

- response:

```bash
{
    "id": 203,
    "name": "Product A",
    "price": "10.0",
    "created_at": "2024-11-22T02:23:30.895Z",
    "updated_at": "2024-11-22T02:23:30.895Z"
}
```

---

### View specific product

#### GET /products/:product_id

- response:

```bash
{
    "id": 203,
    "name": "Product A",
    "price": "10.0",
    "created_at": "2024-11-22T02:23:30.895Z",
    "updated_at": "2024-11-22T02:23:30.895Z"
}
```

---

### Update a specific product

#### PATCH/PUT /products/:product_id

- params:

```bash
{
    "name": "Product BC",
    "price": 20.0
}
```

- response:

```bash
{
    "name": "Product BC",
    "price": "20.0",
    "id": 203,
    "created_at": "2024-11-22T02:23:30.895Z",
    "updated_at": "2024-11-22T02:35:42.648Z"
}
```

---

### Delete a specific product

#### DELETE /products/203

---

### The cart already exists at this point, so we'll simply add a product to it

#### PATCH/PUT /cart

- params:

```bash
{
    "product_id": 204,
    "quantity": 1
}
```

- response:

```bash
{
    "id": 272,
    "products": [
        {
            "id": 204,
            "name": "Product A",
            "quantity": 1,
            "unit_price": 10.0,
            "total_price": 10.0
        }
    ],
    "total_price": 10.0
}
```

---

### View the cart and its added products

#### GET /cart

- response:

```bash
{
    "id": 272,
    "products": [
        {
            "id": 204,
            "name": "Product A",
            "quantity": 1,
            "unit_price": 10.0,
            "total_price": 10.0
        }
    ],
    "total_price": 10.0
}
```

---

### Remove a specific product in the cart

#### GET /cart/:product_id

- response:

```bash
{
    "id": 272,
    "products": [],
    "total_price": 10.0
}
```

---

### Increase the quantity of a specific item in the cart

#### PATCH/PUT /car/add_item

- params:

```bash
{
    "product_id": 204,
    "quantity": 2
}
```

- response:

```bash
{
    "id": 272,
    "products": [
        {
            "id": 204,
            "name": "Product A",
            "quantity": 4,
            "unit_price": 10.0,
            "total_price": 40.0
        }
    ],
    "total_price": 40.0
}
```
