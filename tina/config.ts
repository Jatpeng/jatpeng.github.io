import { defineConfig } from "tinacms";

const branch =
  process.env.GITHUB_BRANCH ||
  process.env.HEAD ||
  "source";

export default defineConfig({
  branch,
  clientId: process.env.TINA_CLIENT_ID,
  token: process.env.TINA_TOKEN,
  build: {
    outputFolder: "admin",
    publicFolder: "source",
  },
  media: {
    tina: {
      mediaRoot: "images/uploads",
      publicFolder: "source",
    },
  },
  schema: {
    collections: [
      {
        name: "post",
        label: "Posts",
        path: "source/_posts",
        format: "md",
        fields: [
          {
            type: "string",
            name: "title",
            label: "Title",
            isTitle: true,
            required: true,
          },
          {
            type: "datetime",
            name: "date",
            label: "Date",
            required: true,
          },
          {
            type: "datetime",
            name: "updated",
            label: "Updated",
            required: false,
          },
          {
            type: "boolean",
            name: "published",
            label: "Published",
            required: false,
          },
          {
            type: "boolean",
            name: "comments",
            label: "Comments",
            required: false,
          },
          {
            type: "boolean",
            name: "copyright",
            label: "Copyright",
            required: false,
          },
          {
            type: "string",
            name: "tags",
            label: "Tags",
            list: true,
            required: false,
          },
          {
            type: "string",
            name: "categories",
            label: "Categories",
            list: true,
            required: false,
          },
          {
            type: "string",
            name: "description",
            label: "Description",
            required: false,
            ui: {
              component: "textarea",
            },
          },
          {
            type: "image",
            name: "cover",
            label: "Cover",
            required: false,
          },
          {
            type: "string",
            name: "typora_root_url",
            nameOverride: "typora-root-url",
            label: "Typora Root URL",
            required: false,
          },
          {
            type: "rich-text",
            name: "body",
            label: "Body",
            isBody: true,
            required: true,
          },
        ],
      },
    ],
  },
});
